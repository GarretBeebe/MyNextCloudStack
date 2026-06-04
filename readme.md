# MyNextCloudStack

A Docker Compose stack running [Nextcloud](https://nextcloud.com/) with PostgreSQL, Redis, and a background cron worker.

## Services

| Service | Image | Port |
|---|---|---|
| `app` | `nextcloud:33.0.5` | `5080` → 80 |
| `db` | `postgres:15.17-bookworm` | `5432` → 5432 |
| `redis` | `redis:7.4.8-bookworm` | — |
| `cron` | `nextcloud:33.0.5` | — |

All services share a bridge network named `nextcloud`.

## Prerequisites

- Docker (20.10+)
- Docker Compose v2

## Configuration

Copy `.env.example` to `.env` and fill in all values before starting:

```bash
cp .env.example .env
```

### Environment variables

| Variable | Description |
|---|---|
| `NEXTCLOUD_ADMIN_USER` | Nextcloud admin username |
| `ADMIN_PASSWORD` | Nextcloud admin password |
| `POSTGRES_DB` | PostgreSQL database name |
| `POSTGRES_USER` | PostgreSQL username |
| `POSTGRES_PASSWORD` | PostgreSQL password |
| `REDIS_PASSWORD` | Redis auth password |
| `HOST_POSTGRES_DATA_DIR` | Host path for PostgreSQL data volume |
| `HOST_NEXTCLOUD_DATA_DIR` | Host path for Nextcloud user data volume |
| `HOST_PHP_INI_PATH` | Host path to `zzz-opcache-tuning.ini` |
| `DNS_SERVER` | DNS server IP for the Nextcloud app container |
| `SMTP_HOST` | SMTP server hostname |
| `SMTP_PORT` | SMTP port (typically 587) |
| `SMTP_AUTHTYPE` | SMTP auth type (e.g. `LOGIN`) |
| `SMTP_NAME` | SMTP login username |
| `SMTP_PASSWORD` | SMTP password or app password |
| `MAIL_FROM_ADDRESS` | Local part of the from address (no `@domain`) |
| `MAIL_DOMAIN` | Domain part of the from address |

## Deployment

Start all services in detached mode:

```bash
docker compose up -d
```

Nextcloud will be available at `http://<host-ip>:5080`.

On first run, Nextcloud uses the `NEXTCLOUD_ADMIN_USER` / `ADMIN_PASSWORD` and database env vars to initialize automatically — no manual setup wizard needed.

## Stopping

```bash
docker compose down
```

To also remove volumes (destructive — data loss):

```bash
docker compose down -v
```

## Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f db
```

## PHP / OPcache tuning

The `app` and `cron` containers mount `php/zzz-opcache-tuning.ini` (path set via `HOST_PHP_INI_PATH`) as a read-only PHP config override. Edit that file to adjust OPcache and JIT settings without rebuilding the image.
