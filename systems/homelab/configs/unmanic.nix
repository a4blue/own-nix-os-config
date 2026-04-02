{config, ...}: let
  serviceDomain = "unmanic.home.a4blue.me";
in {
  ####
  # Main Config
  ####
  modules.unmanic.enable = true;
  ####
  # Permissions
  ####
  users.users.a4blue.extraGroups = ["render" "video"];
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/unmanic";
        mode = "0777";
        user = "nobody";
        group = "nogroup";
      }
    ];
  };
  ####
  # Systemd Service start after mount
  ####
  systemd.services.${config.virtualisation.oci-containers.containers.unmanic.serviceName} = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
  };
  ####
  # Tmpfiles
  ####
  systemd.tmpfiles.settings."unmanic-tmp"."/var/cache/unmanic"."d" = {
    mode = "0777";
    user = "a4blue";
    group = "LargeMediaUsers";
  };
  ####
  # Nginx
  ####
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.unmanic.port}/";
      extraConfig = ''
        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
    locations."/unmanic/websocket" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.unmanic.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;

        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
  };
}
