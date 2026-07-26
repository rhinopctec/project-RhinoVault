#!/usr/bin/env bash
#
# audit_multiarch_images.sh — scan a cloned repo for Docker image references
# and report whether each has both linux/amd64 and linux/arm64 in its manifest.
#
# Usage:
#   ./audit_multiarch_images.sh /path/to/rhinovault-repo
#
# Requires: docker (with manifest inspect access — no login needed for public images)

set -euo pipefail

REPO_DIR="${1:-.}"

if [[ ! -d "$REPO_DIR" ]]; then
  echo "Usage: $0 /path/to/cloned/repo"
  exit 1
fi

echo "==> Scanning $REPO_DIR for image references..."

# Look for common patterns: image: foo:bar, "image": "foo:bar", pull("foo:bar"), etc.
# This is a heuristic, not a perfect parser — review the list before trusting it fully.
IMAGES=$(grep -rhoE "(image['\"]?\s*[:=]\s*['\"])[a-zA-Z0-9_./:-]+" "$REPO_DIR" \
  --include="*.ts" --include="*.yaml" --include="*.yml" --include="*.json" \
  2>/dev/null \
  | sed -E "s/(image['\"]?\s*[:=]\s*['\"])//" \
  | sort -u)

if [[ -z "$IMAGES" ]]; then
  echo "No image references found — check the grep patterns match this codebase's conventions."
  exit 0
fi

echo "Found $(echo "$IMAGES" | wc -l) unique image reference(s):"
echo "$IMAGES"
echo ""
echo "==> Checking each for multi-arch (amd64 + arm64) support..."
echo ""

printf "%-60s %-8s %-8s\n" "IMAGE" "AMD64" "ARM64"
printf "%-60s %-8s %-8s\n" "-----" "-----" "-----"

while IFS= read -r img; do
  [[ -z "$img" ]] && continue
  # Skip obviously non-image strings that slipped through (paths, etc.)
  [[ "$img" == *"/"*"/"*"/"* ]] && continue

  MANIFEST=$(docker manifest inspect "$img" 2>/dev/null || echo "")

  if [[ -z "$MANIFEST" ]]; then
    printf "%-60s %-8s %-8s\n" "$img" "?" "?  (inspect failed — private/invalid/rate-limited?)"
    continue
  fi

  HAS_AMD64="no"
  HAS_ARM64="no"
  echo "$MANIFEST" | grep -q '"architecture": "amd64"' && HAS_AMD64="yes"
  echo "$MANIFEST" | grep -q '"architecture": "arm64"' && HAS_ARM64="yes"

  printf "%-60s %-8s %-8s\n" "$img" "$HAS_AMD64" "$HAS_ARM64"
done <<< "$IMAGES"

echo ""
echo "==> Review any 'no' in the ARM64 column above — those services need a substitute"
echo "    image, your own multi-arch mirror, or should be flagged unsupported on Pi/arm64."
