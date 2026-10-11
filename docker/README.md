# TilBuci — all-in-one Docker image (v25.0)

This folder is a **self-contained distribution package** to build and run the
TilBuci all-in-one container: **Ubuntu + Apache 2.4 + PHP 8 + MariaDB** in a
single image. On the first start the container asks only for the
**administrator e-mail** and the **install mode**, then runs the installer
automatically.

Current packaged version: **25.0** (also published as `latest`).

## Contents

| Path | Purpose |
| --- | --- |
| `Dockerfile` | Image definition (multi-architecture ready) |
| `setup/` | TilBuci installer (source of truth: `setup.php` + `setup/part*.zip` + `setup/database/*.sql`) |
| `docker-entrypoint.sh` | First-run flow: prompts, DB provisioning, installation/update |
| `bin/install.php` | Headless wrapper around the web installer |
| `bin/tilbuci-common.sh` | Shared shell helpers |
| `bin/tilbuci-update` | In-container update tool |
| `bin/tilbuci-set-url` + `bin/tilbuci-set-url.php` | Change the public base URL at runtime |
| `supervisord.conf` | Runs MariaDB and Apache under PID 1 |
| `apache/tilbuci.conf` | Apache virtual host |
| `php/php.ini` | PHP overrides (large ZIP uploads, ZIP extension) |
| `build.sh` | Multi-architecture build/push helper |
| `compose.yaml` | Docker Compose example |
| `VERSION` | Packaged version (`25.0`) |

## Requirements

- Docker 20.10+ (BuildKit/`buildx`) for multi-architecture builds.
- Docker Compose v2 (optional).
- PHP ZIP support is mandatory and is verified during the build (`ZipArchive`).

## Quick start (single host)

Build the image from this folder:

```bash
docker build -t tilbuci:25.0 -t tilbuci:latest .
```

Run it (first start, interactive):

```bash
docker run -it --name tilbuci \
  -p 8080:80 \
  -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ \
  tilbuci:25.0
```

The container asks:

```
TilBuci admin e-mail: usuario@dominio.com
Install mode [multi/single] (default: multi): multi
```

Then open `http://localhost:8080/editor/`. The initial administrator password is
`password` — change it on the first access (Setup in the left menu).

> Always use a **named volume** (`-v tilbuci-data:/data`). Without it, removing
> the container deletes the database and the uploaded media.

### First start without prompts (automation)

```bash
docker run -d --name tilbuci \
  -p 8080:80 \
  -v tilbuci-data:/data \
  -e TILBUCI_EMAIL=admin@example.com \
  -e TILBUCI_INSTALL_MODE=multi \
  -e TILBUCI_URL=http://localhost:8080/ \
  tilbuci:25.0
```

## Multi-architecture

`build.sh` builds `linux/amd64` and `linux/arm64` and tags both `25.0` and
`latest`. Override anything through environment variables.

### Build and push to a registry

```bash
IMAGE=ghcr.io/<owner>/tilbuci PUSH=true ./build.sh
```

Equivalent to:

```bash
IMAGE=ghcr.io/<owner>/tilbuci PUSH=true TAG=25.0 ./build.sh
```

### Build locally (single architecture)

A multi-platform build cannot be loaded into the local Docker engine, so for a
local test build a single platform:

```bash
PLATFORMS=linux/amd64 ./build.sh
```

### Manual buildx (without the script)

```bash
docker buildx create --name tilbuci-builder --use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg TILBUCI_VERSION=25.0 \
  -t <registry>/<owner>/tilbuci:25.0 \
  -t <registry>/<owner>/tilbuci:latest \
  --push .
```

### Verify the published manifest

```bash
docker buildx imagetools inspect <registry>/<owner>/tilbuci:25.0
```

## Docker Compose

```bash
docker compose up --build     # first run (attached: answers the e-mail/mode prompt)
docker compose up -d          # afterwards (set TILBUCI_EMAIL for detached runs)
```

To use a published image instead of building, replace the `build:` block in
`compose.yaml` with `image: <registry>/<owner>/tilbuci:25.0`.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `TZ` | `UTC` | Container time zone |
| `TILBUCI_EMAIL` | *(empty)* | Administrator e-mail. Prompted on first run when empty |
| `TILBUCI_INSTALL_MODE` | `multi` | `multi` or `single` |
| `TILBUCI_URL` | `http://localhost/` | Public base URL; written to `Config.path` and the bases in `player.json`/`editor.json`, and re-applied on every start when set |
| `TILBUCI_DB_NAME` | `tilbuci` | Database name |
| `TILBUCI_DB_USER` | `tilbuci` | Database user |
| `TILBUCI_DB_PASSWORD` | *(generated)* | Database password, persisted in the volume |
| `TILBUCI_AUTO_INSTALL` | `true` | Set to `false` to keep the installer for manual use |
| `TILBUCI_AUTO_UPDATE` | `true` | On start, when the database version is older than the bundled installer, back up the database and update automatically |
| `TILBUCI_KEEP_SETUP` | `false` | Set to `true` to keep `setup.php` reachable after installing |
| `TILBUCI_DATA_DIR` | `/data` | Persistent volume mount point |

## Persistence

The single `/data` volume stores:

- the MariaDB data directory (`/data/mysql`);
- `Config.php`, `player.json`, `editor.json`;
- the `movie`, `font`, `sites` and `pwa` folders;
- automatic database backups taken before updates (`/data/backups`).

These are linked into the web root on every start, so an image update that
overwrites the web files does not affect user data.

> The web application files (`editor/`, the PHP classes under `app/`, `ws/`,
> etc.) are **not** persisted: they live only inside the container. When the
> container is recreated with an existing volume, the entrypoint re-extracts
> them automatically. If the database version is also older than the bundled
> installer, it backs up the database and applies the update.

## Changing the public URL

The container listens on port 80 internally and cannot detect the host port, so
the public URL must be provided through `TILBUCI_URL` (it is re-applied on every
start when set).

Change it while the container is running:

```bash
docker exec -it tilbuci tilbuci-set-url http://localhost:8080/
```

Or recreate the container with the new value:

```bash
docker rm -f tilbuci
docker run -it --name tilbuci -p 8080:80 -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ tilbuci:25.0
```

> Publishing on port 80 (`-p 80:80`) keeps the default `http://localhost/` valid.

## Updating to a new version

1. Replace the contents of `setup/` with the newer installer.
2. Update `VERSION` (for example to `25.1`) and rebuild:

   ```bash
   TAG=25.1 PUSH=true IMAGE=<registry>/<owner>/tilbuci ./build.sh
   ```
3. Recreate the container with the **same volume**. On start, the entrypoint
   compares `config.dbVersion` with the installer version, writes a database
   backup to `/data/backups`, and updates automatically (files + migrations).
   Set `TILBUCI_AUTO_UPDATE=false` to disable this.

Manual alternatives:

```bash
docker exec -it tilbuci tilbuci-update          # CLI
# or open /setup.php in the browser (keep it with TILBUCI_KEEP_SETUP=true)
```

## Container lifecycle (quick reference)

```bash
docker start -a tilbuci        # resume a stopped container (attach to logs)
docker stop tilbuci            # graceful stop
docker rm -f tilbuci           # remove the container (the named volume is KEPT)
docker rm -f tilbuci && docker volume rm tilbuci-data   # full reset (deletes data)
```

If `docker run --name tilbuci` fails with `container name is already in use`,
either `docker start -a tilbuci` (reuse) or `docker rm -f tilbuci` (remove)
before creating a new one. Removing the container does not delete the named
volume; only `docker volume rm tilbuci-data` deletes the data.

## Publishing to a registry

```bash
# Docker Hub
IMAGE=<user>/tilbuci PUSH=true TAG=25.0 ./build.sh

# GitHub Container Registry
echo "$CR_PAT" | docker login ghcr.io -u <user> --password-stdin
IMAGE=ghcr.io/<owner>/tilbuci PUSH=true TAG=25.0 ./build.sh
```

## Inspecting the container

```bash
docker exec -it tilbuci ls -la /var/www/tilbuci/public_html
docker exec -it tilbuci ls -la /data
docker exec -it tilbuci ls -la /data/backups
docker exec -it tilbuci cat /data/app/Config.php
docker exec -it tilbuci mysql tilbuci -e 'SHOW TABLES;'
docker logs -f tilbuci
```

## Security

- Serve behind a TLS-terminating reverse proxy when exposing TilBuci publicly.
- After installation the installer (`setup.php` and the `setup/` folder) is
  removed from the public root unless `TILBUCI_KEEP_SETUP=true`. The `ws/`
  folder is part of TilBuci and is always kept.
- The database is only reachable through the local socket inside the container.
