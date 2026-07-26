# Adding Your PDF Library to RhinoVault

You want both: (1) PDFs you can just open and read, and (2) PDFs the AI assistant can
search/answer questions from. These are two separate subsystems in the codebase — don't
try to make one do both jobs.

---

## Two destinations, not one

| Goal | Subsystem | Where files live |
|------|-----------|-------------------|
| Browsable library | **Supply Depot app** (Calibre-Web) | `storage/books/` (its own Calibre library folder) |
| AI-searchable | **Knowledge Base / RAG** (Ollama + Qdrant) | `storage/kb_uploads/` |

The codebase already has a Calibre-Web integration — the Dockerfile seeds an empty Calibre
library specifically for it (`install/calibre-empty-library/`), so this is a supported,
tested path, not something you're bolting on yourself.

**Practical approach for "same PDFs, both places":** copy (or hardlink, to save disk) each
PDF into both `storage/books/` and `storage/kb_uploads/`. They serve different purposes and
the KB side will inflate on disk anyway once it's indexed (see below), so don't worry about
the duplication in the source folder.

---

## Step 1 — Browsable library (Calibre-Web)

1. In the Vault Console, install **Calibre-Web** from the Supply Depot catalog if you haven't already.
2. For hundreds of files, don't drag-and-drop through the browser UI — it's painfully slow at that volume. Instead:
   ```bash
   # Copy PDFs directly into the Calibre library's storage volume on the host
   cp /path/to/your/pdfs/*.pdf /opt/rhinovault/storage/books/
   ```
   (Adjust the path to wherever your `management_compose.yaml` bind-mounts Calibre-Web's library folder.)
3. Trigger a library rescan from Calibre-Web's admin UI so it picks up the new files and extracts metadata/covers.

This path is low-risk — Calibre-Web just indexes files for browsing, no embedding, no context-length limits.

---

## Step 2 — AI-searchable (Knowledge Base / RAG)

This is the part that needs more care with hundreds of mixed-size PDFs.

### Known sharp edges (check these against your current version before trusting bulk ingestion)

1. **Large PDFs can fail during embedding.** There's a documented issue where extracted PDF
   text sometimes gets sent to the embedding model in chunks that exceed its context limit,
   causing large PDFs to fail outright rather than being chunked properly.
2. **"Sync Storage" scans more than it should.** The storage-sync scanner has been reported to
   walk the *entire* app storage tree (not just KB-designated folders), which can catch
   non-KB files (like Kiwix's library metadata) and retry them forever as "unsupported file
   type" — flooding the queue and logs.
3. **Scanned/image-only PDFs won't embed meaningfully.** If any of your "mixed sizes" PDFs
   are scanned pages with no text layer, there's nothing for the embedding model to extract —
   they'll either fail or silently produce empty/junk embeddings. Run these through OCR
   (e.g. `ocrmypdf`) *before* ingestion if you want them AI-searchable.
4. **Storage multiplies 5–10x once indexed.** Indexed content in Qdrant typically uses 5–10×
   the original file size on disk. For "hundreds" of PDFs, total your source corpus size and
   multiply by ~10 to sanity-check free disk against the built-in guardrail (which warns/blocks
   around 50GB indexed or <10% free disk).

Since this is your fork, you can check `admin/docs/release-notes.md` (or the GitHub issues on
the upstream repo) to see whether these specific bugs are already fixed in the version you
forked from — if not, you may want to patch `embed_file_job.ts` (chunking) and the Sync
Storage scan scope yourself, since you now own the code.

### Recommended workflow given "hundreds, mixed sizes"

1. **Calculate your storage budget first:**
   ```bash
   du -sh /path/to/your/pdfs/
   ```
   Multiply that number by ~10 and confirm you have that much free disk before starting.

2. **Split out anything risky** before ingestion:
   - Scanned/image-only PDFs → run through OCR first, or set aside as "browse-only" (they'll still work fine in Calibre-Web from Step 1, just won't be AI-searchable without OCR)
   - Anything over ~100MB → consider whether it really needs to be AI-searchable, or if it's better left browse-only; large reference books rarely need whole-document embedding to be useful in chat

3. **Copy files into `kb_uploads/` in small batches, not all at once:**
   ```bash
   # See batch_copy_pdfs.sh in this kit — copies N files at a time with a pause
   # between batches so you can watch the Processing Queue for failures
   ./batch_copy_pdfs.sh /path/to/your/pdfs /opt/rhinovault/storage/kb_uploads 25 30
   #                                                                          ^batch size ^seconds between batches
   ```

4. **Trigger Sync Storage** from the Knowledge Base settings in the Vault Console (or `POST /api/rag/sync` if you're scripting it) after each batch, not continuously — this avoids the mixed-tree rescanning issue compounding across a huge backlog.

5. **Watch for stuck jobs:**
   ```bash
   docker logs -f rhinovault_admin | grep -i "file-embeddings"
   ```
   If you see the same job ID retrying repeatedly, kill that job/file rather than letting it retry indefinitely — it's very likely a scanned PDF or a file that needs chunking fixes.

6. Once a batch completes cleanly, move to the next batch.

---

## Suggested order of operations
1. Calibre-Web install + bulk copy to `storage/books/` (Step 1) — do this first, it's safe and gives you a working browsable library immediately regardless of how the KB side goes.
2. Storage budget check (Step 2.1)
3. Pre-sort: OCR scanned PDFs, flag oversized ones (Step 2.2)
4. Batch-copy + sync + monitor (Step 2.3–2.6), starting with a small test batch of ~10 files before committing to the full run
