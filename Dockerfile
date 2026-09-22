ARG DEBIAN_FRONTEND=noninteractive

ARG LIBGOUROU_IMAGE=docker.io/bcliang/docker-libgourou:ubuntu
FROM ${LIBGOUROU_IMAGE}

ARG ONLEIHARR_VERSION=0.3.0b3

ARG ONLEIHARR_SOURCE=onleiharr==${ONLEIHARR_VERSION}

ARG IMAGE_SUFFIX=""

ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}

RUN apt-get update && apt-get install -y git pipx && apt-get clean

# Playwright + Chromium browser — heavy (~300MB), rarely changes.
# Install in a standalone venv first so the browser download is cached
# regardless of ONLEIHARR_SOURCE changes (stable vs dev builds).
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
RUN pipx install playwright && \
    /root/.local/pipx/venvs/playwright/bin/python -m playwright install --with-deps chromium

# Onleiharr — changes between stable/dev builds.
# Inject playwright into the venv; browsers already cached in /ms-playwright.
RUN pipx install "${ONLEIHARR_SOURCE}" && pipx ensurepath
RUN pipx inject onleiharr playwright

ENV PATH="/root/.local/bin:${PATH}"

VOLUME ["/config"]
VOLUME ["/downloads"]

ENTRYPOINT ["onleiharr"]
CMD ["-c", "/config/onleiharr.toml"]
