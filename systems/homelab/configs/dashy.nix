{config, ...}: {
  services.dashy = {
    enable = true;
    virtualHost.domain = "start.home.a4blue.me";
    virtualHost.enableNginx = true;
  };
  services.nginx.virtualHosts."${config.services.dashy.virtualHost.domain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
  };
}
