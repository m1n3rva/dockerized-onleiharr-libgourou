ARG DEBIAN_FRONTEND=noninteractive

ARG LIBGOUROU_IMAGE=docker.io/bcliang/docker-libgourou:ubuntu
FROM ${LIBGOUROU_IMAGE}

ARG ONLEIHARR_VERSION=0.3.0b3

ARG ONLEIHARR_SOURCE=onleiharr==${ONLEIHARR_VERSION}

ARG IMAGE_SUFFIX=""

ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}

RUN apt-get update && apt-get install -y git pipx && apt-get clean

RUN pipx install "${ONLEIHARR_SOURCE}" && pipx ensurepath

# Install Playwright (for OIDC automated login) and Chromium browser.
# Inject playwright into the onleiharr venv so its console scripts land
# in /root/.local/bin (already on PATH via pipx ensurepath).
# --with-deps installs the system libraries Chromium needs at build time.
# Use the venv Python directly since injected console scripts may not
# appear in /root/.local/bin (pipx inject installs packages, not always apps).
# Set PLAYWRIGHT_BROWSERS_PATH BEFORE install so the browser caches there.
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
RUN pipx inject onleiharr playwright && \
    /root/.local/pipx/venvs/onleiharr/bin/python -m playwright install --with-deps chromium

ENV PATH="/root/.local/bin:${PATH}"

VOLUME ["/config"]
VOLUME ["/downloads"]

ENTRYPOINT ["onleiharr"]
CMD ["-c", "/config/onleiharr.toml"]
