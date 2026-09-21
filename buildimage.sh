#!/bin/bash
set -eu

IMAGE_TAG="${1:-}"

case "$IMAGE_TAG" in
  dev)
    echo "Building dev image from OIDC fork..."
    podman build \
      --build-arg ONLEIHARR_SOURCE=git+https://github.com/m1n3rva/Onleiharr.git@oidc_autologin \
      -t dockerized-onleiharr-libgourou:dev .
    ;;
  *)
    podman build -t dockerized-onleiharr-libgourou .
    ;;
esac