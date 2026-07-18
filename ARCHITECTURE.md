# rssnook architecture

This document describes the main runtime boundaries and data flows for contributors. rssnook is a single-user application: one Compose stack owns one SQLite database and serves one trusted household or private network.

## Runtime services

| Service | Technology | Responsibility |
|---|---|---|
| `nginx` | nginx | Exposes port 7755 and routes `/api/*` to the backend and all other requests to the frontend |
| `backend` | FastAPI, SQLAlchemy, APScheduler | API, feed polling, extraction, search, automation, and digest generation |
| `frontend` | SvelteKit | Server-rendered application shell and interactive reader UI |
| `rsshub` | RSSHub | Converts supported websites and social sources into feeds |
| `ollama` | Ollama | Runs the configured summary and digest model locally |

The backend and frontend are not exposed directly by the base Compose file. nginx is the only host-facing service.

## Backend structure

```text
backend/app/
├── main.py          FastAPI application and startup lifecycle
├── config.py        Environment-backed deployment settings
├── database.py      Async engine, schema creation, FTS5, and small migrations
├── models.py        SQLAlchemy data model
├── schemas.py       API request and response types
├── routers/         HTTP endpoints grouped by resource
└── services/
    ├── extractor.py     Full-text article extraction
    ├── fetcher.py       Feed discovery, polling, normalization, and rules
    ├── llm.py           Ollama summaries, digests, and classification
    ├── scheduler.py     Polling, digest, and retention jobs
    └── smart_search.py  Saved-search expansion and matching
```

FastAPI's lifespan initializes the database, seeds a new installation from `seeds/feeds.opml`, starts scheduled jobs, and stops them during a graceful shutdown.

## Frontend structure

```text
frontend/src/
├── app.html / app.css
├── routes/               SvelteKit pages
└── lib/
    ├── api.js            Fetch wrapper for backend endpoints
    ├── sanitize.js       DOMPurify boundary for untrusted HTML
    ├── stores/           Shared Svelte state
    └── components/       Navigation, article lists, reader, and dialogs
```

The shared application store owns navigation and cached feed/topic state. Routes own page-specific query and loading state. Article HTML crosses a deliberate sanitization boundary before it is rendered.

## Primary data flows

### Feed ingestion

1. A user adds a direct feed URL or a webpage from which a feed can be discovered.
2. The backend validates the target and normalizes source-specific URLs.
3. The scheduler or a manual refresh parses the feed and deduplicates entries by URL.
4. Trafilatura extracts readable content and metadata for new articles.
5. Mute filters and automation rules are applied before the transaction commits.
6. SQLite triggers keep the FTS5 index synchronized with article inserts, updates, and deletes.

### Reading

1. The frontend requests paginated article summaries from `/api/articles`.
2. Opening an article fetches its complete record, marks it read, and renders sanitized content in the reader panel.
3. Highlights, notes, tags, bookmarks, and Read Later state are persisted through focused API endpoints.

### Local AI

1. The backend assembles article titles and excerpts for the requested operation.
2. The prompt is sent to the configured Ollama service on the private Compose network.
3. Generated summaries or digests are stored in SQLite so repeated views do not regenerate them.

rssnook does not require a hosted model provider. Operators can point `OLLAMA_BASE_URL` at another trusted Ollama instance if desired.

## Storage and migrations

The default database is `data/rssnook.db`, mounted at `/app/data/rssnook.db` in the backend container. The backend creates missing tables and FTS5 triggers at startup and applies additive column migrations for older installations.

The container entrypoint also handles the project rename: when the default database URL is active and `rssnook.db` does not yet exist, a legacy `rss_reader.db` file is moved into place before the backend starts.

Ollama model data is stored separately in the Docker volume `rssnook_ollama_data`.

## Security boundaries

- nginx is the only host-published service in the base deployment.
- The application assumes every client that can reach port 7755 is trusted; there is no authentication or tenant isolation.
- Feed and article content is untrusted input and must remain behind URL validation and HTML sanitization boundaries.
- RSSHub and Ollama are internal dependencies and should not be published unless the operator secures them separately.
- The `data` directory contains personal reading data and should never be committed.

See [SECURITY.md](SECURITY.md) for deployment guidance and vulnerability reporting.
