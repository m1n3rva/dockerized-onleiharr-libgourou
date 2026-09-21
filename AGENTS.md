# dockerized-onleiharr-libgourou

## Project
see README.md

## Stack
- Base: `bcliang/docker-libgourou:ubuntu` (libgourou 0.8.9)
  - sources in https://github.com/bcliang/docker-libgourou/tree/main
- Tool: `pipx` → `onleiharr 0.3.0b3` (pinned in `Dockerfile:4`, update via `ARG ONLEIHARR_VERSION`)
  - sources in https://github.com/nzb-tuxxx/Onleiharr
  - fork with OIDC autologin: https://github.com/m1n3rva/Onleiharr/tree/oidc_autologin
- Container Engine: `podman`
- Build: `bash buildimage.sh`
- Run:  `bash runimage.sh`
- Smoke tests: `podman run --rm dockerized-onleiharr-libgourou:latest /tests/smoke.sh`
- CI workflows: `.github/workflows/auto-update.yml` (scheduled update), `.github/workflows/docker-publish.yml` (build/push)
- Playwright + Chromium (for OIDC automated login): installed via `pipx inject onleiharr playwright` and `playwright install --with-deps chromium` in `Dockerfile:12-13`



## Configuration
Place `onleiharr.toml` in the config volume (see Onleiharr docs).