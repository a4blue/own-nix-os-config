{config, ...}: let
  serviceDomain = "start.home.a4blue.me";
  dataDir = "/var/lib/homarr";
in {
  modules.homarr.enable = true;
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = dataDir;
        mode = "0777";
        user = "nobody";
        group = "nogroup";
      }
    ];
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.homarr.port}/";
    };
    locations."/websockets" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.modules.homarr.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
      '';
    };
  };
  sops.secrets."homarrEnv" = {
    owner = "nobody";
    group = "nogroup";
    mode = "0777";
  };
}
