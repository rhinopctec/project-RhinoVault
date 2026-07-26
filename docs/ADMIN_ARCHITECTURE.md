# `admin/` Architecture — Where to Add Custom Features

The Command Center ("Vault Console" in RhinoVault) is an [AdonisJS](https://adonisjs.com/)
app (Node/TypeScript backend) with an [Inertia.js](https://inertiajs.com/) + React frontend,
MySQL for storage, and Redis for jobs/caching. It manages other Docker containers via the
"Docker-outside-of-Docker" pattern (talks to the host's Docker socket, doesn't run Docker
inside itself).

## Backend (`admin/app/`) — request/response and business logic

```
app/
├── controllers/    # HTTP endpoints — one per feature area (chats, maps, benchmark, zim, etc.)
├── services/       # Business logic — this is where most feature work happens
├── models/         # Lucid ORM models (database tables)
├── jobs/           # Background/queued work (downloads, benchmarks, auto-updates)
├── middleware/     # Request middleware (compression, JSON forcing, static map serving)
├── validators/     # VineJS request validation schemas
├── exceptions/     # Custom exception handling
└── utils/          # Pure helper functions
```

**Adding a new integrated tool/service (like they did for Kiwix, Ollama, etc.) touches, in order:**
1. `constants/service_names.ts` — register the new service's container name
2. `app/services/<new>_service.ts` — install/start/stop/configure logic, talks to `docker_service.ts`
3. `app/controllers/<new>_controller.ts` — HTTP surface
4. `app/validators/<new>.ts` — request validation
5. `start/routes.ts` — wire up the routes
6. `database/migrations/` — new migration if you need new tables (`node ace make:migration`)
7. `inertia/pages/` + a new sidebar entry in `inertia/lib/navigation.ts` — frontend page + nav link

**Adding a Supply Depot app (one-click catalog, lighter-weight than a fully "integrated" tool):**
- Look at `supply_depot_controller.ts` + `constants/supply_depot_docs.ts` + `container_registry_service.ts`
  — this is the extensibility point they already built for "bring your own container," so custom
  apps you want in the catalog likely belong here rather than as a brand-new integrated service.

## Frontend (`admin/inertia/`) — React + Inertia + Tailwind

```
inertia/
├── pages/          # One file per route — this is what Inertia renders per-page
├── components/     # Shared UI (buttons, modals, tables) + feature folders (chat/, maps/, systeminfo/)
├── layouts/         # AppLayout, SettingsLayout, MapsLayout, DocsLayout — wrap pages
├── hooks/          # Data-fetching/state hooks (useSystemInfo, useDownloads, etc.)
├── providers/      # React context providers (Theme, Modal, Notification)
├── lib/            # Client-side helpers, incl. navigation.ts (sidebar structure) and icons.ts
└── css/app.css     # Global styles — this is where your BRAND_GUIDE.md CSS vars go
```

**For rebranding specifically:**
- `providers/ThemeProvider.tsx` + `hooks/useTheme.ts` — dark/light mode switch; hook your CSS vars in here
- `lib/navigation.ts` — sidebar labels/icons, if you rename any feature areas
- `components/StyledSidebar.tsx`, `StyledButton.tsx`, `StyledModal.tsx` — shared primitives; retheme once here rather than per-page
- `layouts/AppLayout.tsx` — likely where the logo/app name renders in the header

## Notable subsystems worth knowing about before you extend anything

- **Auto-update system** (`jobs/auto_update_job.ts`, `services/auto_update_service.ts`, `utils/update_window.ts`) — has its own dry-run test harness (`node ace auto-update:dry-run`). If you fork this, decide early whether RhinoVault points at your own GitHub releases feed for update checks or disables this feature — the version-check logic (`providers/version_check_provider.ts`) likely hits `projectnomad.us`/GitHub API and needs repointing.
- **Content auto-update** (`content_auto_update_job.ts`, `content_auto_update_backoff.ts`) — separate pipeline for updating installed *content* (ZIMs, maps) vs. the *app itself*. Don't conflate these when customizing.
- **RAG/Knowledge Base pipeline** (`rag_controller.ts`, `rag_service.ts`, `kb_ingest_state.ts`, `kb_ratio_registry.ts`, `embed_file_job.ts`) — this is the most complex subsystem; if you plan to swap Qdrant for something else or change embedding behavior, start by reading `kb_ingest_decision.ts` and `kb_job_health.ts` to understand the state machine before touching the service layer.
- **Collections** (root `collections/*.json`) — curated content catalogs (Kiwix categories, map regions, creator packs) validated by a CI workflow (`validate-collection-urls.yml`). If RhinoVault will offer its own curated content packs, this is a config-only extension point — no backend code changes needed, just new JSON entries (see `admin/docs/community-add-ons.md` for the pattern community add-ons already use).

## Suggested order for adding your first custom feature
1. Get comfortable in `services/` + `controllers/` for one existing simple feature (e.g. `docs_controller.ts` is probably the simplest — good for orientation)
2. Decide: new integrated service, or Supply Depot catalog app? (Supply Depot is much less work if it fits)
3. Prototype the service layer + a migration if needed
4. Wire controller + routes
5. Build the Inertia page + nav entry last, once the API works via curl/Postman
