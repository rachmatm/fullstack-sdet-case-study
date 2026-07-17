# The Platform

A two-service application used for the Quality Engineer case study. It is provided as a single repository so the whole thing clones, runs, and releases as one unit.

```
.
├── api/    # Backend service (Ruby on Rails, PostgreSQL, Redis/Sidekiq)
└── web/    # Frontend web app (React 18 + TypeScript, Vite, Tailwind)
```

The two services run together: the web app talks to the API over REST and WebSocket.

## Running it locally

Each service has its own setup guide. Run the API first, then the web app pointed at it.

1. **API** — see [`api/README.md`](api/README.md). Rails app; needs Ruby (see `api/.ruby-version`), PostgreSQL, and Redis. It serves on `http://localhost:3001`.
2. **Web** — see [`web/README.md`](web/README.md). Vite app; `npm install`, copy `.env.example` to `.env`, point `VITE_API_BASE_URL` at the API, then `npm run dev`. It serves on `http://localhost:5173`.

## Running it with Docker

The repo now includes a local Docker stack for:

- `db` — PostgreSQL
- `redis` — Redis
- `api` — Rails API on `http://localhost:3001`
- `sidekiq` — background jobs
- `web` — Vite frontend on `http://localhost:5173`

Start everything:

```bash
docker compose up --build
```

The API container will:

- install gems if needed
- prepare the database
- run seeds
- create a local admin user automatically

Default local login:

- email: `admin@test-corp.local`
- password: `password123!`
- tenant scheme: `test-corp`

Important note:

- interview flows that actually call Gemini still need valid `GEMINI_*` environment variables if you want the live AI interview behavior to work end to end

## Notes for the case study

- This is the codebase you assess, harden, and release. Treat it as a version about to ship to a client.
- Work in the `/assessment` folder at the repo root for your written deliverables; code changes go in `api/` or `web/`.
- See the case-study brief you were given for what to produce and how it is evaluated.
