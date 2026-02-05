{config, ...}: let
  servicePort = 8025;
  serviceDomain = "mailpit.home.a4blue.me";
in {
  services.mailpit.instances."homelab" = {};
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    extraConfig = ''
      client_max_body_size 20M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        allow 192.168.178.1/24;
        deny all;
      '';
    };
  };
  #users.users.lldap = {
  #  name = "lldap";
  #  group = "lldap";
  #  isSystemUser = true;
  #};
}
