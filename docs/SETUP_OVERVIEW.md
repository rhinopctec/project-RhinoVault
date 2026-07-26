# RhinoVault Setup Guide
### (a rebrand/fork of Crosstalk-Solutions/project-nomad)

This walks through all four stages: fork it, run it, rebrand it, and put it in your own repo with CI.

---

## 0. License check (do this first)

Project N.O.M.A.D. is **Apache-2.0**. That means you're free to fork, modify, rebrand,
and redistribute it — including commercially — as long as you:

- Keep the original `LICENSE` file (Apache-2.0) in the repo.
- Keep a `NOTICE`/attribution file crediting Crosstalk-Solutions and stating what you changed.
- Don't imply Crosstalk-Solutions endorses RhinoVault (don't reuse their trademark/logo/name in a way that suggests affiliation).

Practically: swap the logo and name, add a line in your README like:

> RhinoVault is a fork of [Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) by Crosstalk-Solutions, licensed under Apache-2.0.

---

## 1. Fork it

On GitHub:
1. Go to https://github.com/Crosstalk-Solutions/project-nomad
2. Click **Fork** → uncheck "Copy the main branch only" if you want tags/releases too.
3. Rename the fork itself: Settings → repository name → `rhinovault`.

Locally:
```bash
git clone https://github.com/<your-username>/rhinovault.git
cd rhinovault
git remote add upstream https://github.com/Crosstalk-Solutions/project-nomad.git
```
Keeping `upstream` lets you pull in future N.O.M.A.D. updates/security fixes later with
`git fetch upstream && git merge upstream/main`.

---

## 2. Get it running locally

Per their README, requirements are a Debian-based OS (Ubuntu recommended) and Docker.

**Quick path (their installer, before you've rebranded anything, just to see it work):**
```bash
sudo apt-get update && sudo apt-get install -y curl
curl -fsSL https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/refs/heads/main/install/install_nomad.sh -o install_nomad.sh
sudo bash install_nomad.sh
```
Then visit `http://localhost:8080`.

**Advanced/dev path (what you actually want, since you'll be editing code):**
```bash
cd rhinovault
docker compose -f install/management_compose.yaml up -d --build
```
You'll likely want `--build` (not just `up -d`) once you start editing source, so Docker
rebuilds from your local code instead of pulling their published images.

Repo layout to know:
- `admin/` — the Command Center app itself (the TypeScript management UI/API — 94.8% of the codebase, so this is where nearly all rebranding work happens)
- `collections/` — content collections (Kiwix ZIMs, Kolibri channels, etc.)
- `install/` — install/uninstall/update shell scripts + the Docker Compose template
- `Dockerfile`, `package.json` — root build config

---

## 3. Rebrand to RhinoVault

Use the `rebrand.sh` script (in this kit) — run it from the repo root **after** step 1/2,
**before** you start customizing features, so future upstream merges stay simple.

```bash
chmod +x rebrand.sh
./rebrand.sh /path/to/rhinovault
```

What it does:
- Text replace across source/docs (case-preserving): `N.O.M.A.D.` → `RhinoVault`, `nomad` → `rhinovault`, `NOMAD` → `RHINOVAULT`
- Renames `install_nomad.sh`, `uninstall_nomad.sh`, `update_nomad.sh`, `start_nomad.sh`, `stop_nomad.sh` → `install_rhinovault.sh` etc.
- Updates default install path references (`/opt/project-nomad` → `/opt/rhinovault`)
- Flags (but doesn't touch) the logo file and any hardcoded URLs (discord invite, projectnomad.us, roadmap.projectnomad.us) so you replace those manually with your own.
- Leaves `LICENSE` untouched and appends a `NOTICE` file with the required attribution.

**Manual steps the script can't do for you:**
- New logo/favicon — replace `admin/public/project_nomad_logo.webp` and any other brand assets under `admin/public/`.
- Discord/community links, `projectnomad.us` website references, and the benchmark leaderboard URL — these point to their live services; you'll want your own or remove them.
- Color scheme / theme — check `admin/` for a Tailwind config or theme file and adjust brand colors there.
- Package name in `package.json` (`name`, `description`, `repository`, `author` fields) — the script updates the display name but double-check these.

---

## 4. Your own repo, CI, and releases

- Since you kept `upstream` as a remote, you can periodically pull security/bugfixes without redoing the rebrand (the script is idempotent-ish, but re-run it after big merges).
- Their repo uses `semantic-release` (`.releaserc.json`) and an `ace auto-update:dry-run` command for testing self-update logic — you can keep this pattern, just update version tags to your own scheme.
- Set your `GITHUB_TOKEN`/registry secrets in your fork's Actions settings if you want to publish your own Docker images (check `.github/workflows/` for their existing CI pipeline to adapt).
- Update the Docker Compose template's image references if you plan to publish to your own container registry rather than pulling `crosstalksolutions/*` images directly.

---

## Suggested order of operations
1. Fork + clone (step 1)
2. Get it running unmodified, confirm it works (step 2)
3. Run `rebrand.sh` (step 3)
4. Swap logo/assets, community links (step 3, manual)
5. Push to your own repo, wire up CI (step 4)
6. Only then start adding/removing features
