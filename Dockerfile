ARG LIBGOUROU_IMAGE
FROM ${LIBGOUROU_IMAGE}

ARG ONLEIHARR_VERSION=0.3.0b3

RUN apt-get update && apt-get install -y pipx && apt-get clean
RUN pipx install onleiharr==${ONLEIHARR_VERSION} && pipx ensurepath

ENV PATH="/root/.local/bin:${PATH}"

VOLUME ["/config"]
VOLUME ["/downloads"]

ENTRYPOINT ["onleiharr"]
CMD ["-c", "/config/onleiharr.toml"]
