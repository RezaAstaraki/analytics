# Analytics

Event analytics service (visitors, sessions, events). Local stack uses SQL Server + Adminer; apps are NestJS (`backned`) and Next.js (`pannel-app`).

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running)
- Node.js 20+ (for API and panel)
- Free ports: **1433** (SQL Server), **8080** (Adminer), plus **3000** / Nest default when you run the apps

If you already have containers named `sqlserver` or `adminer` (or something else using 1433/8080), stop/remove them first:

```bash
docker stop sqlserver adminer
docker rm sqlserver adminer
```

## 1. Clone and configure env

```bash
git clone <repo-url> analytics
cd analytics
cp .env.example .env
```

Edit `.env` if you want a different SA password (must be strong: upper, lower, number, symbol).

## 2. Start database

```bash
docker compose up -d
```

Wait until SQL Server is healthy:

```bash
docker compose ps
```

| Service   | URL / port        | Notes                                      |
|-----------|-------------------|--------------------------------------------|
| SQL Server| `localhost:1433`  | user `sa`, password from `.env`            |
| Adminer   | http://localhost:8080 | System: **MS SQL**, Server: **`sqlserver`**, Username: `sa` |

On first start, `init-scripts/` creates sample `TestDB` (runs once per data volume).

Stop:

```bash
docker compose down
```

Data persists in the `sqlserver-data` Docker volume. To wipe DB and re-run init scripts:

```bash
docker compose down -v
docker compose up -d
```

## 3. Start the API (NestJS)

```bash
cd backned
npm install
npm run start:dev
```

## 4. Start the panel (Next.js)

```bash
cd pannel-app
npm install
npm run dev
```

Panel defaults to http://localhost:3000.

## Project layout

```text
analytics/
  docker-compose.yml    # SQL Server + Adminer
  .env.example          # copy to .env
  entrypoint.sh         # SQL init on first boot
  init-scripts/         # schema/seed (dev sample for now)
  backned/              # NestJS API
  pannel-app/           # Next.js dashboard
```

## Troubleshooting

- **`container name already in use`** — another stack owns `sqlserver`/`adminer`; stop/rm those containers (see above).
- **Port already allocated** — free 1433/8080 or change published ports in `docker-compose.yml`.
- **Adminer can’t connect** — use host `sqlserver` (Docker service name), not `localhost`, when connecting from the Adminer container.
- **Init scripts didn’t run again** — expected; they run once. Use `docker compose down -v` for a clean database.
