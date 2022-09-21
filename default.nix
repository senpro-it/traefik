{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "docker.io/library/traefik:latest";
        ports = [ "80:80/tcp" "[::]:80:80/tcp" "443:443/tcp" "[::]:443:443/tcp" ];
        extraOptions = [
          "--net=proxy"
        ];
        volumes = [
          "/srv/podman/traefik/volume.d/traefik:/etc/traefik"
        ];
        autoStart = true;
      };
    };
    system.activationScripts = {
      makeTraefikBindVolDirectories = ''
        mkdir -p /srv/podman/traefik/volume.d/traefik/cert.d
      '';
    };
  };
}
