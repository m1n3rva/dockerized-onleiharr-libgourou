#!/bin/bash
set -ue 

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p $SCRIPT_DIR/onleiharr/{config,downloads}

podman run \
  --replace \
  --name onleiharr \
  --restart unless-stopped \
  -v $SCRIPT_DIR/onleiharr/config:/config \
  -v $SCRIPT_DIR/onleiharr/downloads:/downloads \
  -it \
  dockerized-onleiharr-libgourou:latest $@