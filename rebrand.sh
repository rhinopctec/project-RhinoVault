#!/usr/bin/env bash
#
# rebrand.sh — Rebrand a cloned project-nomad repo to RhinoVault
#
# Usage:
#   ./rebrand.sh /path/to/rhinovault
#
# Run this from inside the rebrand kit, pointing at your cloned repo.
# Safe to re-run (it's mostly idempotent), but always work on a clean
# git branch so you can review the diff before committing.

set -euo pipefail

REPO_DIR="${1:-}"

if [[ -z "$REPO_DIR" || ! -d "$REPO_DIR" ]]; then
  echo "Usage: $0 /path/to/cloned/rhinovault-repo"
  exit 1
fi

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "Warning: $REPO_DIR doesn't look like a git repo root. Continuing anyway."
fi

cd "$REPO_DIR"

echo "==> Rebranding repo at: $REPO_DIR"
echo "==> Make sure you're on a clean branch (e.g. git checkout -b rebrand/rhinovault)"
read -p "Continue? [y/N] " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

# ---------------------------------------------------------------------------
# 1. File/folder renames (do this before text replacement so paths line up)
# ---------------------------------------------------------------------------
echo "==> Renaming install scripts..."
declare -A RENAMES=(
  ["install/install_nomad.sh"]="install/install_rhinovault.sh"
  ["install/uninstall_nomad.sh"]="install/uninstall_rhinovault.sh"
  ["update_nomad.sh"]="update_rhinovault.sh"
  ["start_nomad.sh"]="start_rhinovault.sh"
  ["stop_nomad.sh"]="stop_rhinovault.sh"
)

for old in "${!RENAMES[@]}"; do
  new="${RENAMES[$old]}"
  if [[ -f "$old" ]]; then
    git mv "$old" "$new" 2>/dev/null || mv "$old" "$new"
    echo "   renamed: $old -> $new"
  fi
done

# ---------------------------------------------------------------------------
# 2. Text replacement across source & docs
#    Order matters: most-specific patterns first.
# ---------------------------------------------------------------------------
echo "==> Replacing brand strings in text files..."

# File types to touch. Add more extensions if needed (.vue, .toml, etc.)
FILE_TYPES=(-name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
            -o -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.yaml" \
            -o -name "*.yml" -o -name "*.env*" -o -name "Dockerfile" -o -name "*.html")

FILES=$(find . \( "${FILE_TYPES[@]}" \) \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  -not -path "./dist/*" \
  -not -path "./build/*")

# Case-preserving replacements, most specific first
REPLACEMENTS=(
  "s/N\.O\.M\.A\.D\./RhinoVault/g"
  "s/Project NOMAD/RhinoVault/g"
  "s/project-nomad/rhinovault/g"
  "s/PROJECT_NOMAD/RHINOVAULT/g"
  "s/NOMAD/RHINOVAULT/g"
  "s/Nomad/Rhinovault/g"
  "s/nomad/rhinovault/g"
)

for f in $FILES; do
  for expr in "${REPLACEMENTS[@]}"; do
    sed -i.bak -E "$expr" "$f" 2>/dev/null && rm -f "$f.bak"
  done
done

echo "==> Updating default install path references (/opt/project-nomad -> /opt/rhinovault)..."
for f in $FILES; do
  sed -i.bak "s|/opt/project-nomad|/opt/rhinovault|g" "$f" 2>/dev/null && rm -f "$f.bak"
done

# ---------------------------------------------------------------------------
# 3. Flag things that need manual attention
# ---------------------------------------------------------------------------
echo ""
echo "==> Scanning for things you'll need to replace MANUALLY:"
echo ""

echo "-- Logo/brand assets --"
find . -iname "*nomad*logo*" -o -iname "*nomad*.webp" -o -iname "*nomad*.png" -o -iname "*nomad*.svg" 2>/dev/null | grep -v node_modules || echo "  (none found)"

echo ""
echo "-- Live URLs pointing at Crosstalk-Solutions' services (replace or remove) --"
grep -rIl "projectnomad\.us\|discord\.com/invite/crosstalksolutions\|roadmap\.projectnomad\.us" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.md" --include="*.json" \
  --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null || echo "  (none found)"

echo ""
echo "-- package.json fields to review --"
find . -maxdepth 2 -name "package.json" -not -path "./node_modules/*" 2>/dev/null

# ---------------------------------------------------------------------------
# 4. NOTICE file for Apache-2.0 attribution
# ---------------------------------------------------------------------------
if [[ ! -f "NOTICE" ]]; then
  echo "==> Writing NOTICE file (Apache-2.0 attribution)..."
  cat > NOTICE <<'EOF'
RhinoVault
Copyright 2026 <your name/org here>

This product is a derivative work of Project N.O.M.A.D.
(https://github.com/Crosstalk-Solutions/project-nomad),
Copyright Crosstalk-Solutions, licensed under the Apache License, Version 2.0.

RhinoVault is not affiliated with or endorsed by Crosstalk-Solutions.

See the LICENSE file for the full Apache-2.0 license text.
EOF
fi

echo ""
echo "==> Done. Review the diff with: git diff --stat"
echo "==> Then handle the manually-flagged items above before committing."
