# TilBuci — all-in-one Docker image

Self-contained TilBuci image: **Ubuntu + Apache 2.4 + PHP 8 + MariaDB** in a
single container. The first run needs no startup prompt or extra parameters:
the application address redirects to the browser installer, which asks for the
**administrator e-mail**, the **initial password** and the **access mode**.

## Contents

| Path | Purpose |
| --- | --- |
| `Dockerfile` | Image build definition |
| `setup/` | TilBuci installer (source of truth, replaced on each release) |
| `docker-entrypoint.sh` | First-run flow: DB provisioning, installation |
| `bin/install.php` | Headless wrapper around the web installer |
| `bin/tilbuci-common.sh` | Shared shell helpers |
| `bin/tilbuci-update` | In-container update tool |
| `bin/tilbuci-set-url` + `bin/tilbuci-set-url.php` | Change the public base URL at runtime |
| `supervisord.conf` | Runs MariaDB and Apache as PID 1 children |
| `apache/tilbuci.conf` | Apache virtual host (DocumentRoot, FollowSymLinks) |
| `php/php.ini` | PHP overrides (large ZIP uploads, ZIP extension) |
| `../compose.yaml` | Example Docker Compose file (repository root) |
| `../.github/workflows/docker-publish.yml` | CI: build multi-arch and publish to GHCR |

## Requirements

- Docker.
- PHP ZIP support is mandatory: the image ships `php-zip` (`ZipArchive`) and the
  `zip`/`unzip` utilities, and the build fails if `ZipArchive` is unavailable.

## Build

Run these commands from the **repository root** (the directory that contains
the `docker/` folder — otherwise you get `path "./docker" not found`):

```bash
docker build -t tilbuci:latest ./docker
```

## Run

### First start

Start the container normally — no startup prompt and no extra parameters are
required (the first run behaves like the following ones):

```bash
docker run -d --name tilbuci \
  -p 8080:80 \
  -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ \
  tilbuci:latest
```

Then open `http://localhost:8080/`. The address is redirected to the installer
(`setup.php?docker=true`), which asks only for the administrator e-mail, an
initial password and the access mode — the database connection is already
configured. When it finishes, the installer removes itself and the container
keeps running normally.

Afterwards access `http://localhost:8080/editor/`.

> Always use a **named volume** (`-v tilbuci-data:/data`). Without it, removing
> the container deletes the database and the uploaded media.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `TZ` | `UTC` | Container time zone |
| `TILBUCI_URL` | `http://localhost/` | Public base URL. Written to `Config.path` and the bases in `player.json`/`editor.json`, and re-applied on every start when set |
| `TILBUCI_DB_NAME` | `tilbuci` | Database name |
| `TILBUCI_DB_USER` | `tilbuci` | Database user |
| `TILBUCI_DB_PASSWORD` | `S3nh4Dogg0` | Password of the `tilbuci` database user, stored in the volume. Override it for public deployments |
| `TILBUCI_AUTO_UPDATE` | `true` | On start, when the installed database version is older than the bundled installer, back up the database and run the update automatically |
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

> The web application files themselves (`editor/`, the PHP classes under
> `app/`, `ws/`, etc.) are **not** persisted: they live only inside the
> container. When the container is recreated with an existing volume, the
> entrypoint detects their absence and re-extracts them automatically from the
> installer. If the database version is also older than the bundled installer,
> it backs up the database to `/data/backups` and applies the update — see
> [Updating](#updating). Your configuration and data are preserved.

## Initial credentials

The first visit to the application address opens the installer, where you choose
the administrator e-mail, an initial password and the access mode (`multi` or
`single`). The database connection is preconfigured (user `tilbuci`); nothing else
is asked.

## Changing the public URL

TilBuci stores the public base URL in its configuration. The container listens
on port 80 internally and cannot detect the host port, so the public URL must be
provided through `TILBUCI_URL` (it is re-applied on every start when set).

To change it while the container is running:

```bash
docker exec -it tilbuci tilbuci-set-url http://localhost:8080/
```

To change it permanently, restart the container with the new value:

```bash
docker rm -f tilbuci
docker run -d --name tilbuci -p 8080:80 -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ tilbuci:latest
```

> Publishing on port 80 (`-p 80:80`) keeps the default `http://localhost/`
> valid and requires no configuration.

## Updating

Replace the contents of `setup/` with a newer installer, rebuild the image and
recreate the container with the same volume:

```bash
docker build -t tilbuci:latest ./docker
docker rm -f tilbuci
docker run -it --name tilbuci -p 8080:80 -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ tilbuci:latest
```

On start the entrypoint compares the database version (`config.dbVersion`) with
the installer version. When the database is older, it writes a database backup
to `/data/backups` and runs the update automatically (files + database
migrations). Set `TILBUCI_AUTO_UPDATE=false` to disable the automatic update.

Backups are named `/data/backups/pre-update-<from>-<timestamp>.sql`. To restore
one:

```bash
docker exec tilbuci sh -c 'mysql tilbuci < /data/backups/pre-update-24-XXXXXXXXXXXXXX.sql'
```

Manual alternatives:

- **In the browser:** open `/setup.php` and follow the update prompt (keep the
  installer available with `TILBUCI_KEEP_SETUP=true`).
- **From the CLI:** run the update inside the container:

  ```bash
  docker exec -it tilbuci tilbuci-update
  ```

## Container lifecycle

`docker run` always **creates a new container**; `docker start`/`docker stop`
operate on an existing one.

Resume a stopped container:

```bash
docker start -a tilbuci     # start and attach to the logs
```

Recreate (needed to change `-e`/`-p` or after rebuilding the image):

```bash
docker rm -f tilbuci        # removes the container; the named volume is KEPT
docker run -it --name tilbuci -p 8080:80 -v tilbuci-data:/data \
  -e TILBUCI_URL=http://localhost:8080/ tilbuci:latest
```

If you see `Conflict. The container name "/tilbuci" is already in use`, the name
is taken by an existing (possibly stopped) container:

```bash
docker ps -a                # list all containers, including stopped ones
docker start -a tilbuci     # reuse the existing one, or
docker rm -f tilbuci        # remove it before creating a new one, or
docker rename tilbuci tilbuci-old
```

Data safety:

- `docker rm tilbuci` deletes the container but keeps the named volume `tilbuci-data`.
- Only `docker volume rm tilbuci-data` deletes the data.
- A plain `docker start` reuses the variables from creation; to change an
  environment variable you must recreate the container.

## Inspecting the container

Files:

```bash
docker exec -it tilbuci ls -la /var/www/tilbuci/public_html   # web root
docker exec -it tilbuci ls -la /data                          # persisted data
docker exec -it tilbuci ls -la /data/backups                  # pre-update DB backups
docker exec -it tilbuci cat /data/app/Config.php
docker exec -it tilbuci bash                                  # full shell
```

Copy files in and out:

```bash
docker cp tilbuci:/data/app/player.json ./player.json
docker cp ./movie.zip tilbuci:/data/movie/
```

Database:

```bash
docker exec -it tilbuci mysql tilbuci -e 'SHOW TABLES;'
docker exec tilbuci cat /data/.db_password   # internal database user password
```

Logs and processes:

```bash
docker logs -f tilbuci
docker top tilbuci
docker exec tilbuci supervisorctl status
```

## Distributing the image

### Publish to a registry

> Run from the **repository root** so the context `./docker` resolves. Replace
> the placeholder **values** below. Do **not** keep angle brackets (`<` and
> `>`) in a shell command — they are redirection operators and cause errors
> such as `bash: <name>: No such file or directory`.

Docker Hub:

```bash
DOCKERHUB_USER=your-dockerhub-username    # edit this line

docker login
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg TILBUCI_VERSION=26 \
  --build-arg DOCKER_VERSION=26.0.0 \
  -t "${DOCKERHUB_USER}/tilbuci:26.0.0" \
  -t "${DOCKERHUB_USER}/tilbuci:latest" \
  --push ./docker
```

GitHub Container Registry (GHCR):

```bash
GHCR_OWNER=your-github-owner     # user or organization (edit this line)
GHCR_REPO=tilbuci                # repository/package name

echo "$CR_PAT" | docker login ghcr.io -u "${GHCR_OWNER}" --password-stdin
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg TILBUCI_VERSION=26 \
  --build-arg DOCKER_VERSION=26.0.0 \
  -t "ghcr.io/${GHCR_OWNER}/${GHCR_REPO}:26.0.0" \
  -t "ghcr.io/${GHCR_OWNER}/${GHCR_REPO}:latest" \
  --push ./docker
```

### Multi-architecture build

The `buildx` commands above already target `linux/amd64` and `linux/arm64` in a
single invocation and push a manifest list with a variant per architecture.

### Offline distribution

```bash
docker save tilbuci:latest -o tilbuci-image.tar
# on the target machine:
docker load -i tilbuci-image.tar
```

### Build from source

Version the `docker/` folder; users rebuild locally with:

```bash
docker build -t tilbuci:latest ./docker
```

### Docker Compose

The `compose.yaml` at the repository root provides a ready-to-use setup:

```bash
docker compose up --build     # build the image and start
docker compose up -d          # detached
```

The first run needs no prompt: open the application address to complete the
setup in the browser. To use a published image instead of building, replace the
`build:` block in `compose.yaml` with, for example, `image: tilbuci/tilbuci:latest`.
The packaged `docker/distro/compose.yaml` already ships with that image.

### Continuous integration

[`.github/workflows/docker-publish.yml`](../.github/workflows/docker-publish.yml:1)
builds the image for `linux/amd64` and `linux/arm64` and pushes it to GHCR on
tag pushes (`v*` or numeric tags) and on manual runs. Tag releases in step with
the Docker package version (for example `26.0.0`).

## Security

- Serve behind a TLS-terminating reverse proxy when exposing TilBuci publicly.
- After installation the installer (`setup.php` and the `setup/` folder) is
  removed from the public root unless `TILBUCI_KEEP_SETUP=true`. The `ws/`
  folder is part of TilBuci and is always kept.
- The database is only reachable through the local socket inside the container.
