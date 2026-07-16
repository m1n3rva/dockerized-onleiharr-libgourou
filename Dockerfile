# TODO: pin the docker-libgourou version to ensure consitent behavior
FROM docker.io/bcliang/docker-libgourou:ubuntu

RUN apt-get update && apt-get install -y pipx && apt-get clean
RUN pipx install onleiharr==0.3.0b3 && pipx ensurepath

ENV PATH="/root/.local/bin:${PATH}"

VOLUME ["/config"]
VOLUME ["/downloads"]

ENTRYPOINT ["onleiharr"]
CMD ["-c", "/config/onleiharr.toml"]
