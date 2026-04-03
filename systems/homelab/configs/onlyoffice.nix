{config, ...}: let
  serviceDomain = "onlyoffice.home.a4blue.me";
in {
  ####
  # Main Config
  ####
  services.onlyoffice = {
    enable = true;
    wopi = true;
    hostname = serviceDomain;
    securityNonceFile = config.sops.secrets."onlyoffice/Nonce".path;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwtSecretFile".path;
  };
  ####
  # Secrets
  ####
  sops.secrets = {
    "onlyoffice/Nonce" = {
      owner = "onlyoffice";
      group = "onlyoffice";
      mode = "440";
    };
    "onlyoffice/jwtSecretFile" = {
      owner = "onlyoffice";
      group = "onlyoffice";
    };
  };
  ####
  # Nginx
  ####
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
      proxyPass = "http://127.0.0.1:${builtins.toString config.services.onlyoffice.port}";
    };
  };
}
