{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.senpro.oci-containers.traefik;

in

{

  options = {
    senpro.oci-containers.traefik.extraConfig = mkOption {
      type = types.lines;
      default = ''
        certificatesResolvers:
          letsEncrypt:
            acme:
              storage: /etc/traefik/cert.d/acme.json
              httpChallenge:
                entryPoint: http2-tcp
      '';
      example = ''
        certificatesResolvers:
          letsEncrypt:
            acme:
              storage: /path/to/my/containerized/acme.json
              httpChallenge:
                entryPoint: http2-tcp
      '';
      description = ''
        Apply additional static configurations, e.g. for `certificatesResolvers`.
      '';
    };
  };

  config = {
    virtualisation.oci-containers.containers = {
      traefik = {
        image = "docker.io/library/traefik:latest";
        ports = [ "80:80/tcp" "[::]:80:80/tcp" "443:443/tcp" "[::]:443:443/tcp" ];
        extraOptions = [
          "--net=proxy"
        ];
        volumes = [
          "traefik:/etc/traefik"
        ];
        autoStart = true;
      };
    };
    systemd.services = {
      "podman-traefik" = {
        postStart = ''
          ${pkgs.coreutils-full}/bin/printf '%s\n' \
          "providers:" \
          "  file:" \
          "    directory: /etc/traefik/conf.d" \
          "    watch: true" \
          "" \
          "entrypoints:" \
          "  http2-tcp:" \
          "    address: :80/tcp" \
          "    http:" \
          "      redirections:" \
          "        entryPoint:" \
          "          to: https2-tcp" \
          "          scheme: https" \
          "  https2-tcp:" \
          "    address: :443/tcp" \
          "" \
          "${cfg.extraConfig}" \
          "experimental:" \
          "  http3: true" > $(${pkgs.podman}/bin/podman volume inspect traefik --format "{{.Mountpoint}}")/traefik.yml
          ${pkgs.coreutils-full}/bin/mkdir -p $(${pkgs.podman}/bin/podman volume inspect traefik --format "{{.Mountpoint}}")/{cert.d,conf.d}
          ${pkgs.coreutils-full}/bin/printf '%s\n' \
          "http:" \
          "  middlewares:" \
          "    httpsSec:" \
          "      headers:" \
          "        browserXssFilter: true" \
          "        contentTypeNosniff: true" \
          "        frameDeny: true" \
          "        sslRedirect: true" \
          "        stsIncludeSubdomains: true" \
          "        stsPreload: true" \
          "        stsSeconds: 31536000" \
          "        customFrameOptionsValue: SAMEORIGIN" \
          "tls:" \
          "  options:" \
          "    default:" \
          "      cipherSuites:" \
          "        - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" \
          "        - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" \
          "        - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305" \
          "        - TLS_AES_128_GCM_SHA256" \
          "        - TLS_AES_256_GCM_SHA384" \
          "        - TLS_CHACHA20_POLY1305_SHA256" \
          "      curvePreferences:" \
          "        - CurveP521" \
          "        - CurveP384" \
          "      minVersion: VersionTLS12" > $(${pkgs.podman}/bin/podman volume inspect traefik --format "{{.Mountpoint}}")/conf.d/main.yml
        '';
      };
    };
  };

}
