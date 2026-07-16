# dockerized-onleiharr-libgourou

## Project
see README.md

## Stack
- Base: `bcliang/docker-libgourou:ubuntu` (libgourou 0.8.9)
  - sources in https://github.com/bcliang/docker-libgourou/tree/main
- Tool: `pipx` → `onleiharr 0.2.1`
  - sources in https://github.com/nzb-tuxxx/Onleiharr
- Container Engine: `podman`
- Build: `bash buildimage.sh` 
- Run:  `bash runimage.sh`



## Configuration
Place `onleiharr.toml` in the config volume (see Onleiharr docs).