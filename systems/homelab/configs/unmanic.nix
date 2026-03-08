{config, ...}: let
  serviceDomain = "unmanic.home.a4blue.me";
  servicePort = 7578;
in {
  virtualisation.oci-containers.containers = {
    unmanic = {
      image = "docker.io/josh5/unmanic:latest";
      autoStart = true;
      ports = ["127.0.0.1:${builtins.toString servicePort}:8888"];
      volumes = [
        "/var/lib/unmanic:/config"
        "/LargeMedia/smb:/library"
        "/var/cache/unmanic:/tmp/unmanic"
        "/dev/dri:/dev/dri"
      ];
      environmentFiles = [config.sops.secrets."homarrEnv".path];
      environment = {
        PUID = "${builtins.toString config.users.users.a4blue.uid}";
        PGID = "${builtins.toString config.users.groups.LargeMediaUsers.gid}";
      };
    };
  };
  users.users.a4blue.extraGroups = ["render" "video"];
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
  systemd.services.${config.virtualisation.oci-containers.containers.unmanic.serviceName} = {
    after = ["LargeMedia.mount" "bcachefs-large-media-mount.service"];
  };
  systemd.tmpfiles.settings."unmanic-tmp"."/var/cache/unmanic"."d" = {
    mode = "0777";
    user = "a4blue";
    group = "LargeMediaUsers";
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
      extraConfig = ''
        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
    locations."/unmanic/websocket" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Protocol $scheme;

        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
  };
}
