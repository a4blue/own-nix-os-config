{config, ...}: let
  servicePort = 5000;
  serviceDomain = "ombi.home.a4blue.me";
in {
  services.ombi = {
    enable = true;
    port = servicePort;
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    extraConfig = ''
      client_max_body_size 512M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
      '';
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/ombi";
        mode = "0740";
        user = "ombi";
        group = "ombi";
      }
    ];
  };
}
