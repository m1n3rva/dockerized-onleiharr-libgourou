# dockerized-onleiharr-libgourou

Dockerized [Onleiharr](https://github.com/nzb-tuxxx/Onleiharr) with [libgourou](https://forge.soutade.fr/soutade/libgourou/) ACSM downloader for the German Onleihe library service.

Onleiharr monitors Onleihe products and categories, sends notifications for new media, and can auto-lend items. libgourou can download the actual epub files (acsmdownloader).

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
