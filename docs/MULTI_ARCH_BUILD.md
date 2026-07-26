# RhinoVault: One Image, Both Architectures (amd64 + arm64)

## The concept
Instead of building separate amd64 and arm64 images and picking one at install time, you build
**both platforms under one tag** using Docker Buildx, and push a single multi-arch manifest.
When someone runs `docker compose up` on an amd64 machine, Docker pulls the amd64 layer. Same
tag, same compose file, on a Pi5 — Docker pulls the arm64 layer instead. No architecture
detection logic needed anywhere in your install script or compose file.

---

## Option A — Build via GitHub Actions (recommended: build once, use everywhere)

Your fork already has `.github/workflows/build-primary-image.yml`. Modify the build step to
target both platforms and use QEMU + Buildx so the amd64 runner can also produce an arm64 layer:

```yaml
name: Build Primary Docker Image (multi-arch)

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Semantic version (no "v" prefix, e.g. "1.0.0")'
        required: true
        type: string
      tag_latest:
        description: 'Also tag as :latest?'
        required: false
        type: boolean
        default: false

jobs:
  build:
    name: Build multi-arch image
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - name: Checkout code
        uses: actions/checkout@v6

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
        with:
          platforms: arm64

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v4
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push (amd64 + arm64)
        uses: docker/build-push-action@v7
        with:
          push: true
          platforms: linux/amd64,linux/arm64
          tags: |
            ghcr.io/rhinopctec/rhinovault:${{ inputs.version }}
            ghcr.io/rhinopctec/rhinovault:v${{ inputs.version }}
            ${{ inputs.tag_latest && 'ghcr.io/rhinopctec/rhinovault:latest' || '' }}
          build-args: |
            VERSION=${{ inputs.version }}
            BUILD_DATE=${{ github.event.workflow_run.created_at }}
            VCS_REF=${{ github.sha }}
```

Key changes from the original: `docker/setup-qemu-action` + `docker/setup-buildx-action` added,
and `platforms: linux/amd64,linux/arm64` on the build step. The arm64 half of the build runs
under QEMU emulation *during CI* (slower build, ~2-4x), but the **resulting image runs
natively** on whichever architecture pulls it — the emulation cost is paid once at build time,
not by every user at runtime. This is the opposite tradeoff from the QEMU-at-runtime approach
we discussed for the Pi, and it's the right one here since CI build time is cheap and doesn't
affect end-user performance.

Trigger it from the Actions tab with a version number, same as the original release flow.

## Option B — Build locally without CI (quick iteration, no push required)

```bash
# One-time setup: enable QEMU + create a buildx builder that supports multi-platform
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --name rhinobuilder --use
docker buildx inspect --bootstrap

# Build both platforms. --push required for multi-platform (can't --load locally,
# since a single "image" here is really a manifest pointing at two separate images)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/rhinopctec/rhinovault:dev \
  --build-arg VERSION=dev \
  --push \
  .
```

If you don't want to push to a registry yet, build one platform at a time with `--load` into
your local Docker (this gives you a single-arch image for testing on whichever machine you run
the command on — useful for iterating before you're ready to publish a real multi-arch tag).

## Step — Point your compose file at the multi-arch tag

Same `install/management_compose.yaml` change as before, but now the tag itself is multi-arch,
so **no per-architecture branching needed**:

```yaml
services:
  admin:
    image: ghcr.io/rhinopctec/rhinovault:latest   # resolves to the right arch automatically
```

Same for `install_rhinovault.sh` — it doesn't need architecture-detection logic added, since
`docker compose pull`/`up` already does the right thing against a multi-arch manifest.

---

## The part that still needs manual verification: dependent services

Your Command Center image is now multi-arch. The services *it* installs at runtime (Ollama,
Kiwix, Kolibri, MySQL, Redis, Qdrant, Calibre-Web, etc.) are separate images, pulled based on
whatever tags/digests are hardcoded in the service registry (check
`admin/database/seeders/service_seeder.ts` and `admin/constants/service_names.ts` for where
these are defined). Most upstream images are already multi-arch, but you should verify each one
rather than assume:

```bash
# Check whether a given image+tag has both platforms in its manifest
docker manifest inspect ollama/ollama:latest | grep -A2 architecture
docker manifest inspect qdrant/qdrant:latest | grep -A2 architecture
docker manifest inspect mysql:8 | grep -A2 architecture
docker manifest inspect redis:7 | grep -A2 architecture
docker manifest inspect ghcr.io/kiwix/kiwix-serve:latest | grep -A2 architecture
```

Use `audit_multiarch_images.sh` (in this kit) to scan the codebase for image references and
check all of them at once, rather than checking one by one by hand.

If any come back amd64-only, you have three options, in order of preference:
1. Check if the upstream project publishes a separate arm64-tagged image you can pin to instead (many do, just not under the same tag)
2. Build/maintain your own multi-arch mirror of that one image, same Buildx approach as above
3. Mark that specific service as "not available on arm64" in your fork's UI/docs rather than letting it silently fail on Pi installs
