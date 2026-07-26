# Deploying RhinoVault on Raspberry Pi 5 (8GB RAM, 1TB storage)

## Read this first: the ARM64 gap

Project N.O.M.A.D. (and by extension your fork, until you patch it) **only publishes official
Docker images for linux/amd64**. There's an open, unresolved upstream feature request asking
for arm64 support — the maintainers' own stated blocker is exactly this: no published arm64
images, and some install-time assumptions that don't flex for Pi hardware (default ports, etc).

**The workaround, and what this guide does:** build the Command Center image yourself, directly
on the Pi5. This isn't cross-compilation — the Pi5 *is* arm64 hardware, so `docker build` on it
produces a native arm64 image with no emulation needed. The Dockerfile already has arm64
handling built in (it downloads an arm64 build of `go-pmtiles` for the maps feature), so this
is a supported build target even though the maintainers don't publish the resulting image.

**What's NOT guaranteed:** the *other* containers the Command Center installs at runtime
(Ollama, Kiwix, Kolibri, MySQL, Redis, Qdrant, Calibre-Web, etc.) are pulled independently, not
built from your Dockerfile. Most of these upstream projects do publish arm64 images. The risk
is that N.O.M.A.D.'s service registry pins specific image tags/digests it has tested — if any
of those pins point to an amd64-only digest (rather than a multi-arch manifest tag), that
specific service will fail with an "exec format error" even though an arm64 build of that
software exists elsewhere. **Test each service install one at a time and check logs**, rather
than assuming the whole catalog works day one.

---

## Hardware setup

### Storage: don't run this off a microSD card
You mentioned 1TB storage — make sure that's an **NVMe SSD via the Pi5's PCIe HAT/M.2 adapter**
(or at minimum a USB 3.0 SSD). This stack runs MySQL, Redis, Qdrant, and constant Docker layer
writes 24/7 — a microSD card will both bottleneck performance and wear out fast. Boot Raspberry
Pi OS itself from the same NVMe drive if possible (Pi5 supports NVMe boot) rather than SD-boot
with NVMe as secondary storage.

### Cooling
Building the Docker image and running several containers simultaneously (especially if you
install Ollama) will push sustained CPU load. Use an active-cooling case (official Pi5 Active
Cooler or equivalent) — thermal throttling under sustained load will silently degrade
performance and make troubleshooting confusing (a slow response might be throttling, not a
real bug).

### RAM budget reality check (8GB total)
Rough per-service memory footprint once running (varies with load):

| Service | Approx. RAM |
|---|---|
| Command Center (admin) + MySQL + Redis | ~1–1.5 GB combined |
| Qdrant (idle/light use) | ~0.3–0.5 GB |
| Kiwix | ~0.2–0.5 GB (depends on ZIM size cached) |
| Kolibri | ~0.3–0.5 GB |
| Ollama, **without** a model loaded | ~0.1–0.3 GB |
| Ollama, **with** a 3B quantized model loaded | ~3–4 GB |
| Ollama, **with** a 7B+ quantized model loaded | 6–8+ GB — will not comfortably fit alongside everything else |

With 8GB total and the OS itself needing headroom, **plan to run small quantized models only
(1B–3B parameters, Q4 quantization)** if you install the AI Assistant locally on the Pi. A 7B+
model will either fail to load, swap heavily, or starve every other container. If you want
larger models, use the built-in "remote Ollama host" setting to point at a beefier machine
elsewhere on your network instead of running inference on the Pi itself — this is a supported
config option, not a hack.

---

## Step 1 — OS and base packages

```bash
# Raspberry Pi OS Lite (64-bit), Bookworm — flash to your NVMe/SSD, boot from it
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl git
```

Confirm you're actually on 64-bit before going further — this matters a lot here:
```bash
uname -m
# must print: aarch64  (NOT armv7l — that's 32-bit and won't work)
```

## Step 2 — Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker   # or log out/in
docker compose version   # confirm the compose plugin is present
```

Configure log rotation up front so container logs don't slowly eat your 1TB drive over months
of uptime:
```bash
sudo tee /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
EOF
sudo systemctl restart docker
```

## Step 3 — Clone your fork and build the image locally

```bash
git clone https://github.com/rhinopctec/project-RhinoVault.git
cd project-RhinoVault

# Native arm64 build — this runs directly on the Pi's own architecture, no QEMU needed
docker build -t rhinovault:local \
  --build-arg VERSION=dev-arm64 \
  .
```

This will take a while on Pi5 hardware (Node dependency install + build) — expect 10–20+
minutes depending on cooling/throttling. Grab coffee.

## Step 4 — Point the Compose file at your local image

Open `install/management_compose.yaml` (rename to `docker-compose.yml` per the Advanced
Installation approach) and change the Command Center service's `image:` line from the
published `ghcr.io/...` reference to your locally built tag:

```yaml
services:
  admin:
    image: rhinovault:local   # was: ghcr.io/crosstalk-solutions/project-nomad:...
    # ...rest unchanged
```

While you're in there:
- Point volume bind mounts at your NVMe/SSD mount path (e.g. `/mnt/vault/storage:/app/storage` instead of a default relative path)
- Check for port conflicts with anything else on your network (8080 for the Command Center, plus whatever MySQL/Redis expose) — the FAQ notes core services support port overrides via this compose file today; installable apps (Ollama etc.) don't yet support custom ports, so plan your network accordingly

## Step 5 — Bring it up

```bash
mkdir -p /mnt/vault/storage/logs
chmod 775 /mnt/vault/storage /mnt/vault/storage/logs

docker compose -f management_compose.yaml up -d
docker compose -f management_compose.yaml logs -f admin
```

Watch for `exec format error` in the logs — that's the tell-tale sign a pulled dependency
image (MySQL, Redis) doesn't have the arm64 variant your compose file expects. Both MySQL and
Redis official images support arm64, so this is unlikely at this stage, but confirm before
moving on.

Visit `http://<pi-ip>:8080` once it's up.

## Step 6 — Install services one at a time via the Vault Console UI

Don't install everything from Supply Depot in one go. Install one service, confirm it starts
cleanly (`docker ps`, check its logs), *then* move to the next:

**Suggested order** (safest/most-tested arm64 upstream images first):
1. Kiwix (kiwix-tools publishes arm64 builds)
2. Redis/MySQL dependents — already covered by core compose
3. Notes (FlatNotes)
4. Data Tools (CyberChef — static, architecture-agnostic)
5. Calibre-Web (for your PDF library)
6. Kolibri (Python-based, generally arm64-friendly, but heavier — watch RAM)
7. **Ollama last**, and start with a small model:
   ```bash
   curl -X POST -H "Content-Type: application/json" \
     -d '{"model":"llama3.2:1b"}' \
     http://localhost:8080/api/ollama/models
   ```
   Confirm it loads and responds before trying anything bigger. If it struggles, switch to
   pointing at a remote Ollama host in AI Assistant settings instead of running inference locally.
8. Qdrant only if you're doing RAG/Knowledge Base search — check RAM headroom first with `docker stats`

## Step 7 — Ongoing monitoring

```bash
docker stats --no-stream          # RAM/CPU per container, right now
free -h                            # overall memory + swap pressure
vcgencmd measure_temp              # check for thermal throttling (if available on your OS image)
df -h /mnt/vault                   # storage headroom
```

If you added a modest swap file as a safety net (recommended on any Pi running Docker), keep
it small (1–2GB) — on sustained heavy swapping the SSD write cycles matter, but occasional
overflow protection is worth it.

---

## Summary checklist

- [ ] NVMe/SSD (not microSD) holds the OS and all Docker data
- [ ] Active cooling installed
- [ ] Raspberry Pi OS 64-bit confirmed (`uname -m` → `aarch64`)
- [ ] Docker + Compose plugin installed, log rotation configured
- [ ] Image built locally (`rhinovault:local`), compose file repointed at it
- [ ] Compose brought up, Command Center reachable, no `exec format error` in logs
- [ ] Services installed one at a time, verified before moving to the next
- [ ] AI Assistant: small quantized model only, or pointed at a remote host
- [ ] `docker stats` checked after each new service install to catch RAM pressure early
