# dockerized-onleiharr-libgourou

Dockerized [Onleiharr](https://github.com/nzb-tuxxx/Onleiharr) with [libgourou](https://forge.soutade.fr/soutade/libgourou/) ACSM downloader for the German [Onleihe](https://www.onleihe.de) library service.

Onleiharr monitors Onleihe products and categories, sends notifications for new media, and can auto-lend items. libgourou downloads the actual ebook files (`.acsm` → `.epub`) and optionally removes DRM.

---

## Quick Start

### Prerequisites

- Docker, Podman, or Docker Compose installed
- Onleihe library account (user credentials)
- Python 3.10+ (for Onleiharr, bundled in the image)

### 1. Get the Image

The image is automatically built and pushed to GitHub Container Registry by CI. To pull it:

```bash
docker pull ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
# or
podman pull ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
```

To build locally:

```bash
./buildimage.sh
```

### 2. Configuration

Create your working directory and config files:

```bash
mkdir -p ~/onleiharr/{config,downloads}
```

#### Onleiharr Configuration

Onleiharr requires a `onleiharr.toml` configuration file. Run the config wizard:

```bash
docker run --rm -it \
  -v ~/onleiharr/config:/config \
  ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest \
  --init-config
```

Fill in your Onleihe credentials (`username`, `password`, `library`, `library_id`) and the URLs of pages you want to monitor.

Alternatively, create the file manually:

```bash
cat > ~/onleiharr/config/onleiharr.toml << 'EOF'
[general]
poll_interval_secs = 300.0
urls = [
  "https://www.onleihe.de/nbib24/frontend/versionInfoList,0-0-0-109-0-0-0-2008-400005-812926447-0.html",  # magazine example
]
keywords = [
  "my-magazine",
]

[notification]
# Uncomment and configure to receive notifications:
# urls = ["tgram://{bot_token}/{chat_id}/?format=html"]  # Telegram
# urls = ["discord://{webhook_url}"]  # Discord

[gourou]
bin_dir = "/usr/local/bin"
download_dir = "/downloads"
download_permissions = "0644"
timeout_secs = 30.0
EOF
```

Find your `library` and `library_id`:

1. Open your library's Onleihe page: `https://www.onleihe.de/nbibXXX/frontend/myBib,0-0-0-100-0-0-0-0-0-0-0.html` (replace `nbibXXX` with your consortium code)
2. Select your library and look at the URL — it contains `libraryId=YYY`
3. The part before the path is `library` (`nbibXXX`), the number is `library_id` (`YYY`)

#### libgourou Setup (optional)

libgourou is already included in the image. Before downloading ebooks, initialize ADEPT once:

```bash
docker run --rm --name adept-init \
  -v ~/onleiharr/config:/config \
  ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest \
  adept_activate --anonymous
```

### 3. Run the Service

#### Option A: Docker Compose (recommended)

Create `docker-compose.yml`:

```yaml
services:
  onleiharr:
    image: ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
    container_name: onleiharr
    restart: on-failure:5
    volumes:
      - ~/onleiharr/config:/config
      - ~/onleiharr/downloads:/downloads
    environment:
      - TZ=Europe/Berlin
```

Start the service:

```bash
docker compose up -d
```

#### Option B: Podman

```bash
mkdir -p ~/onleiharr/{config,downloads}

podman run \
  --replace \
  --name onleiharr \
  --restart on-failure:5 \
  -v ~/onleiharr/config:/config \
  -v ~/onleiharr/downloads:/downloads \
  -it \
  ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
```

#### Option C: Wrapper script

```bash
./runimage.sh
```

### 4. Verify It's Running

Check logs:

```bash
docker logs -f onleiharr
# or
podman logs -f onleiharr
```

Check the container status:

```bash
docker ps --filter name=onleiharr
```

---

## Running as a Background Service

### Docker Compose

The `docker compose up -d` command above already runs the container detached. To stop it:

```bash
docker compose down
```

To update to the latest image:

```bash
docker compose pull && docker compose up -d
```

### Podman

To run in the background (detach):

```bash
podman run \
  --replace \
  --name onleiharr \
  --restart on-failure:5 \
  -d \
  -v ~/onleiharr/config:/config \
  -v ~/onleiharr/downloads:/downloads \
  ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
```

To stop:

```bash
podman stop onleiharr && podman rm onleiharr
```

### Systemd User Service (Podman)

For a persistent system-level service, install a systemd user unit:

```bash
# Run once to create the unit file
docker run --rm -it \
  -v ~/onleiharr/config:/config \
  -v ~/onleiharr/downloads:/downloads \
  ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest \
  --install-as-user-systemd

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable --now onleiharr
```

To check status:

```bash
journalctl --user -u onleiharr -f
```

---

## Configuration Reference

### onleiharr.toml

| Section | Key | Description | Default |
|---------|-----|-------------|---------|
| `[general]` | `poll_interval_secs` | How often to poll monitored URLs | `300.0` |
| | `urls` | List of Onleihe pages to monitor | *(required)* |
| | `keywords` | Keywords to trigger auto-lend | `[]` |
| `[notification]` | `urls` | Apprise notification URLs | *(optional)* |
| | `test_notification` | Send a test notification on startup | `false` |
| `[gourou]` | `bin_dir` | Path to libgourou binaries | `/usr/local/bin` |
| | `download_dir` | Where to save downloaded ebooks | `/downloads` |
| | `download_permissions` | File mode for downloads | `0644` |
| | `timeout_secs` | Download timeout in seconds | `30.0` |
| | `remove_drm` | Enable DRM removal (⚠️ legal considerations) | `false` |
| | `remove_drm_ack` | Acknowledge DRM removal risk | *(required if `remove_drm = true`)* |
| | `lendings_poll_interval_secs` | Interval for scanning "Mein Konto" loans | `21600.0` |
| | `lendings_notify` | Notify on MyBib downloads | `true` |

### Environment Overrides

Override config values with environment variables:

| Variable | Description |
|----------|-------------|
| `ONLEIHARR_CONFIG` | Custom path to `onleiharr.toml` |
| `ONLEIHARR_URLS` | Comma-separated list of monitored URLs |
| `ONLEIHARR_USERNAME`, `ONLEIHARR_PASSWORD` | Onleihe credentials |
| `ONLEIHARR_LIBRARY`, `ONLEIHARR_LIBRARY_ID` | Library identifier |
| `ONLEIHARR_POLL_INTERVAL` | Override poll interval (seconds) |
| `ONLEIHARR_GOUROU_BIN_DIR` | Override libgourou binary directory |
| `ONLEIHARR_GOUROU_DOWNLOAD_DIR` | Override download directory |
| `TZ` | Timezone (e.g. `Europe/Berlin`) |

---

## Available Images

The image is built and published automatically. See the [Automated Updates](#automated-updates) section for details.

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable build (updated automatically) |
| `auto-update-{run_number}` | Each auto-update run gets a unique tag for rollback |
| `sha-{commit}` | Build tied to a specific repository commit |
| `main` | Build from the `main` branch |

Pull the latest:

```bash
docker pull ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
```

---

## Automated Updates

This repository includes an automated update workflow (`.github/workflows/auto-update.yml`) that:

- **Checks** for new versions of `onleiharr` (from PyPI) and the base image (`bcliang/docker-libgourou:ubuntu`)
- **Bumps** the pinned versions in `Dockerfile` via a commit to `main`
- **Builds** the image with the new versions and runs smoke tests
- **Pushes** the updated image to GitHub Container Registry (GHCR)

### Update Policy

| Dependency | Source | Policy |
|---|---|---|
| `onleiharr` | PyPI (pypi.org) | Stable releases only (no pre-releases) |
| Base image (`bcliang/docker-libgourou:ubuntu`) | Docker Hub | Digest-pinned from the `ubuntu` tag |

- **Schedule**: Every Monday at 03:00 UTC, plus manual trigger via GitHub UI
- **Smoke tests**: Verifies `onleiharr --help`, `onleiharr --version`, `acsmdownloader --help`, and `adept_activate --help` all exit 0
- **Downgrade guard**: The workflow never downgrades a version; it only updates when a strictly newer version is available

---

## Troubleshooting

### Container crashes and restarts in a loop

The container is configured with `restart: on-failure:5` (or `--restart on-failure:5`) to **prevent crash loops**. This means Podman/Docker will attempt to restart the container up to **5 times** before giving up.

If your container keeps crashing:

1. Check the logs to identify the error:
   ```bash
   docker logs onleiharr
   # or
   podman logs onleiharr
   ```
2. Common issues:
   - **Missing config**: Ensure `onleiharr.toml` exists and is valid TOML
   - **Invalid credentials**: Test with `docker run --rm -v ~/onleiharr/config:/config ghcr.io/... --once`
   - **Network issues**: Onleiharr needs outbound access to Onleihe servers and notification services
3. Reset the restart counter after fixing the issue:
   ```bash
   docker rm onleiharr  # then start fresh
   ```

### No notifications received

- Verify your Apprise notification URL is correct and test it
- Add `test_notification = true` to `[notification]` in `onleiharr.toml` and restart to send a test
- Check logs with `--log-level DEBUG`:
  ```bash
  docker run ... --log-level DEBUG
  ```

### Downloads not working

- Ensure `acsmdownloader` is in the expected path (`/usr/local/bin` by default)
- Verify ADEPT license is initialized: `adept_activate --anonymous`
- Check that `download_dir` in `[gourou]` maps to a writable volume
- Confirm the `[gourou]` section in `onleiharr.toml` is present and enabled

### How to force an update before the weekly schedule

Run the workflow manually on GitHub:
1. Go to [Actions → Auto-Update Dependencies](https://github.com/m1n3rva/dockerized-onleiharr-libgourou/actions/workflows/auto-update.yml)
2. Click **"Run workflow"** → **"Run workflow"**

Or trigger a rebuild of the latest image:

```bash
docker pull ghcr.io/m1n3rva/dockerized-onleiharr-libgourou:latest
docker compose down && docker compose up -d
```

---

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

---

## License

MIT
