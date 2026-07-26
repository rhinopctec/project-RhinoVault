#!/usr/bin/env bash
#
# batch_copy_pdfs.sh — copy PDFs into a destination folder in small batches,
# pausing between batches so you can watch the Knowledge Base processing
# queue / docker logs for failures before the next batch lands.
#
# Usage:
#   ./batch_copy_pdfs.sh <source_dir> <dest_dir> [batch_size] [pause_seconds]
#
# Example:
#   ./batch_copy_pdfs.sh ~/my-pdfs /opt/rhinovault/storage/kb_uploads 25 30

set -euo pipefail

SRC="${1:-}"
DEST="${2:-}"
BATCH_SIZE="${3:-25}"
PAUSE="${4:-30}"

if [[ -z "$SRC" || -z "$DEST" ]]; then
  echo "Usage: $0 <source_dir> <dest_dir> [batch_size] [pause_seconds]"
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "Source directory not found: $SRC"
  exit 1
fi

mkdir -p "$DEST"

mapfile -d '' FILES < <(find "$SRC" -maxdepth 1 -iname "*.pdf" -print0 | sort -z)
TOTAL=${#FILES[@]}

if [[ "$TOTAL" -eq 0 ]]; then
  echo "No PDFs found in $SRC"
  exit 0
fi

echo "Found $TOTAL PDF(s) in $SRC"
echo "Copying to $DEST in batches of $BATCH_SIZE, pausing ${PAUSE}s between batches"
echo ""

COPIED=0
BATCH_NUM=0

for ((i=0; i<TOTAL; i+=BATCH_SIZE)); do
  BATCH_NUM=$((BATCH_NUM + 1))
  BATCH_END=$((i + BATCH_SIZE))
  [[ $BATCH_END -gt $TOTAL ]] && BATCH_END=$TOTAL

  echo "=== Batch $BATCH_NUM: files $((i+1))-$BATCH_END of $TOTAL ==="
  for ((j=i; j<BATCH_END; j++)); do
    FILE="${FILES[$j]}"
    BASENAME=$(basename "$FILE")
    cp -n "$FILE" "$DEST/$BASENAME"
    echo "  copied: $BASENAME"
    COPIED=$((COPIED + 1))
  done

  echo ""
  if [[ $BATCH_END -lt $TOTAL ]]; then
    echo "--> Batch $BATCH_NUM done. Trigger Sync Storage now, check the Processing"
    echo "    Queue / docker logs for failures, then this script will continue in ${PAUSE}s."
    echo "    (Ctrl+C now if you want to stop and investigate before continuing.)"
    sleep "$PAUSE"
    echo ""
  fi
done

echo ""
echo "Done. Copied $COPIED file(s) to $DEST."
echo "Remember to trigger Sync Storage one more time for the final batch."
