{
  config,
  pkgs,
  ...
}: let
  servicePort = 38050;
  serviceDomain = "sabnzbd.home.a4blue.me";
in {
  imports = [
    ./nginx.nix
  ];
  users.users.sabnzbd.extraGroups = ["smbUser" "LargeMediaUsers"];
  systemd.services.sabnzbd.after = ["LargeMedia.mount"];
  services.sabnzbd.enable = true;
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    enableACME = true;
    extraConfig = ''
      client_max_body_size 20M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
      '';
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/sabnzbd";
        mode = "0740";
        user = "sabnzbd";
        group = "sabnzbd";
      }
    ];
  };
}
