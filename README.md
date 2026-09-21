# dockerized-onleiharr-libgourou

Dockerized [Onleiharr](https://github.com/nzb-tuxxx/Onleiharr) with [libgourou](https://forge.soutade.fr/soutade/libgourou/) ACSM downloader for the German Onleihe library service.

Onleiharr monitors Onleihe products and categories, sends notifications for new media, and can auto-lend items. libgourou can download the actual epub files (acsmdownloader).

## Automated Updates

This repository includes an automated update workflow (`.github/workflows/auto-update.yml`) that:

- **Checks** for new versions of `onleiharr` (from PyPI) and the base image (`bcliang/docker-libgourou`)
- **Bumps** the pinned versions in `Dockerfile` via a commit to `main`
- **Builds** the image with the new versions and runs smoke tests
- **Pushes** the updated image to GitHub Container Registry (GHCR)

### Details

| Dependency | Source | Policy |
|---|---|---|
| `onleiharr` | PyPI (pypi.org) | Stable releases only (no pre-releases) |
| Base image (`bcliang/docker-libgourou:ubuntu`) | Docker Hub | Digest-pinned from the `ubuntu` tag |

- **Schedule**: Every Monday at 03:00 UTC, plus manual trigger via GitHub UI
- **Smoke tests**: Verifies `onleiharr --help`, `onleiharr --version`, `acsmdownloader --help`, and `adept_activate --help` all exit 0
- **Downgrade guard**: The workflow never downgrades a version; it only updates when a strictly newer version is available

## Quick Start

### 1. Build the image

Right now there is no ready-to use image available, you can build it locally using `./buildimage.sh`.


### 2. Configuration

:construction: Details to be documented...

Follow the setup process to create the `onleiharr.toml` config file, see [nzb-tuxxx/Onleiharr](https://github.com/nzb-tuxxx/Onleiharr). 

Also configure [libgourou](https://forge.soutade.fr/soutade/libgourou/) to download the ebooks.


### 3. Run the container manually
To run the image manually and check the configs you can use the wrapper script

```bash
mkdir -p ./onleiharr/{config,downloads}

podman run \
  --replace \
  --name onleiharr \
  --restart unless-stopped \
  -v ./onleiharr/config:/config \
  -v ./onleiharr/downloads:/downloads \
  -it \
  dockerized-onleiharr-libgourou:latest $@
```

### 4. Running the container continuously

:construction: To be documented...

Config snippet to integrate Onleiharr with libgourou for this image:

```toml
[gourou]
bin_dir = "/usr/local/bin"
download_dir = "/downloads"
download_permissions = "0644"
timeout_secs = 30.0
lendings_poll_interval_secs = 1800.0
# lendings_notify = true
```

## Development

For local development/testing, you can use the `buildimage.sh` and `runimage.sh` scripts.

### Smoke tests

A basic smoke test suite verifies that the installed binaries work correctly:

```bash
./buildimage.sh
podman run --rm dockerized-onleiharr-libgourou:latest /tests/smoke.sh
```

Or run them via the provided build script with an override:

```bash
podman build -t smoke-test .
podman run --rm smoke-test /tests/smoke.sh
```

