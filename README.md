# traefik
Configuration snippet for NixOS to spin up a traefik container using Podman.

## :tada: `Getting started`

Create needed working directories with the following command:

```
mkdir -p /srv/podman/traefik/volume.d/traefik/cert.d
```

Create a `proxy` network for Traefik to publish containers like the following:

```
podman network create --ipv6 --gateway fd01::1 --subnet fd01::/80 --gateway 10.90.0.1 --subnet 10.90.0.0/16 proxy
```
