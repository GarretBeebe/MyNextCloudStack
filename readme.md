# MyNextCloudStack

A Docker Compose stack running [Nextcloud](https://nextcloud.com/) with PostgreSQL, Redis, and a background cron worker.

## Services

| Service | Image | Port |
|---|---|---|
| `app` | `nextcloud:34.0.4` | `127.0.0.1:5080` → 80 |
| `db` | `postgres:15.17-bookworm` | `127.0.0.1:5432` → 5432 |
| `redis` | `redis:7.4.8-bookworm` | — |
| `cron` | `nextcloud:34.0.4` | — |

All services share a bridge network named `nextcloud`.

## Prerequisites

- Docker Engine 25+ (the `app` healthcheck uses `start_interval`)
- Docker Compose v2, recent enough to support `start_interval` (tested with v5.5.1)

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

Port 5080 is bound to `127.0.0.1` only, so Nextcloud isn't reachable from the LAN directly: serve it through a reverse proxy on the same host (this setup uses Caddy with host networking). See [Reverse proxy & client IPs](#reverse-proxy--client-ips).

On `docker compose up`, `cron` starts only after `app` passes its healthcheck (installed, not in maintenance mode, no pending DB upgrade), so an image upgrade finishes before background jobs resume. After a host reboot Docker starts both at once; `cron.php` then skips runs on its own while an upgrade is pending or maintenance mode is on. The healthcheck greps the JSON from `status.php`, so if a future image changes that output, update the check in `docker-compose.yaml`.

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

## Apache worker limits

`apache/mpm_prefork.conf` is mounted over the image's prefork config. `MaxRequestWorkers 40` keeps concurrent requests below PostgreSQL's 100 connections and bounds RAM use; `MaxConnectionsPerChild 1000` recycles workers periodically. After an image upgrade, check that the image still reads `/etc/apache2/mods-available/mpm_prefork.conf`.

## Reverse proxy & client IPs

- The reverse proxy (here, Caddy on the host network) proxies to `127.0.0.1:5080`; Docker delivers that traffic from the `nextcloud` bridge's gateway address.
- Set `trusted_proxies` in `config.php` to `172.16.0.0/12` (`docker exec -u www-data nextcloud php occ config:system:set trusted_proxies 0 --value=172.16.0.0/12`). The range covers Docker's default 172.17–172.31 bridge subnets, so it keeps working if `docker compose down`/`up` gives the network a new subnet. This is safe only because port 5080 is bound to `127.0.0.1` and Docker isolates other bridge networks. Once the 172.x range is used up, Docker hands out `192.168.x.0/20` subnets instead; if this network ever lands there, Nextcloud would see every client as the gateway IP, so pin the subnet in `docker-compose.yaml` at that point.
- `APACHE_DISABLE_REWRITE_IP=1` disables the image's Apache `remoteip` config, which trusts a client-supplied `X-Real-IP` header and would let anyone spoof their IP. Client IPs come from the reverse proxy's `X-Forwarded-For` instead. Any value disables it; remove the variable to re-enable.
