# Applying This Kit to Your Fork

This folder mirrors the layout of `project-RhinoVault` (your fork). Everything here is meant
to be copied *into* your existing clone, not used as a standalone repo — your fork already has
the full N.O.M.A.D. codebase (admin/, install/, collections/, etc.); this kit only adds/replaces
the rebranding, docs, and deployment pieces discussed so far.

## What goes where

| File in this kit | Destination in your repo | Action |
|---|---|---|
| `README.md` | `README.md` | **Replace** — rebranded, includes required attribution |
| `NOTICE` | `NOTICE` (new file, repo root) | **Add** — required by Apache-2.0 for derivative works |
| `rebrand.sh` | anywhere convenient, e.g. repo root or `scripts/rebrand.sh` | **Add** — run once to rename N.O.M.A.D. references throughout the codebase |
| `admin/public/rhinovault_logo.svg` | `admin/public/rhinovault_logo.svg` | **Add.** Also export a `.webp`/`.png` version to replace `admin/public/project_nomad_logo.webp` (the README references that filename) |
| `docs/BRAND_GUIDE.md` | `docs/BRAND_GUIDE.md` | **Add** |
| `docs/ADMIN_ARCHITECTURE.md` | `docs/ADMIN_ARCHITECTURE.md` | **Add** |
| `docs/PDF_INGESTION_PLAN.md` | `docs/PDF_INGESTION_PLAN.md` | **Add** |
| `docs/PI5_DEPLOYMENT_GUIDE.md` | `docs/PI5_DEPLOYMENT_GUIDE.md` | **Add** |
| `docs/MULTI_ARCH_BUILD.md` | `docs/MULTI_ARCH_BUILD.md` | **Add** |
| `docs/SETUP_OVERVIEW.md` | `docs/SETUP_OVERVIEW.md` | **Add** — the original fork/run/rebrand/CI overview from earlier in this project |
| `scripts/batch_copy_pdfs.sh` | `scripts/batch_copy_pdfs.sh` | **Add** |
| `scripts/audit_multiarch_images.sh` | `scripts/audit_multiarch_images.sh` | **Add** |
| `.github/workflows/build-primary-image.yml` | `.github/workflows/build-primary-image.yml` | **Replace** — swaps the original amd64-only build for the multi-arch (amd64+arm64) version |

Note: `admin/docs/*` already exists in the upstream codebase (in-app documentation shown inside
the Vault Console UI itself — `about.md`, `faq.md`, `getting-started.md`, etc.). The `docs/`
folder in this kit is a **separate, top-level folder** for repo/dev-facing documentation
(deployment guides, architecture notes) — don't confuse the two or merge them together.

## Steps to push this to GitHub

```bash
# 1. Clone your fork if you haven't already, or cd into your existing clone
git clone https://github.com/rhinopctec/project-RhinoVault.git
cd project-RhinoVault

# 2. Create a branch for this batch of changes
git checkout -b rebrand/initial-setup

# 3. Copy the contents of this kit into your repo
#    (adjust the source path to wherever you extracted this kit)
cp -r /path/to/this-kit/README.md ./README.md
cp -r /path/to/this-kit/NOTICE ./NOTICE
cp -r /path/to/this-kit/rebrand.sh ./rebrand.sh
cp -r /path/to/this-kit/admin/public/rhinovault_logo.svg ./admin/public/rhinovault_logo.svg
mkdir -p docs scripts
cp -r /path/to/this-kit/docs/* ./docs/
cp -r /path/to/this-kit/scripts/* ./scripts/
cp -r /path/to/this-kit/.github/workflows/build-primary-image.yml ./.github/workflows/build-primary-image.yml

chmod +x rebrand.sh scripts/*.sh

# 4. Run the rebrand script to rename N.O.M.A.D. references throughout the rest of the codebase
./rebrand.sh .
# review the diff carefully before committing — it touches a lot of files
git diff --stat

# 5. Commit and push
git add .
git commit -m "chore(rebrand): rebrand to RhinoVault, add deployment docs and multi-arch CI"
git push origin rebrand/initial-setup

# 6. Open a PR on GitHub from rebrand/initial-setup -> main (or main -> main if you're the only contributor and want to push straight there)
```

## Before you push: quick sanity checklist

- [ ] `rebrand.sh` has been run and you've reviewed `git diff` for anything it touched that shouldn't have changed
- [ ] `admin/public/project_nomad_logo.webp` replaced (or README updated to point at the new filename)
- [ ] `NOTICE` and `LICENSE` both present at repo root
- [ ] `.github/workflows/build-primary-image.yml` references `ghcr.io/rhinopctec/...` (adjust if you're using a different GitHub username/org or registry)
- [ ] Repo secrets configured if you plan to actually run the CI build: `DEPLOYMENT_AUTHORIZED_USERS` (comma-separated list including your GitHub username) so the auth-check job in the workflow passes
