# traefik
Configuration snippet for NixOS to spin up a traefik container using Podman.

## :tada: `Getting started`

Clone the repository into the directory `/srv/podman/traefik`. The path can't be changed for now!

Add the following statement to your `imports = [];` in `configuration.nix` and do a `nixos-rebuild`:

```
/srv/podman/traefik/default.nix { }
```

Create a `proxy` network for Traefik to publish containers like the following:

```
podman network create --ipv6 --gateway fd01::1 --subnet fd01::/80 \
  --gateway 10.90.0.1 --subnet 10.90.0.0/16 proxy
```

Ensure `pkgs.dnsname-cni` is listed in `containers.containersConf.cniPlugins`, otherwise Traefik will have problems finding your other containers.
