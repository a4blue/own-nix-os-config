{config, ...}: let
  servicePort = 8000;
  serviceDomain = "onlyoffice.home.a4blue.me";
in {
  services.onlyoffice = {
    enable = true;
    wopi = true;
    hostname = serviceDomain;
    securityNonceFile = config.sops.secrets."onlyoffice/Nonce".path;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwtSecretFile".path;
  };
  sops.secrets."onlyoffice/Nonce" = {
    owner = "onlyoffice";
    group = "onlyoffice";
    mode = "440";
  };
  sops.secrets."onlyoffice/jwtSecretFile" = {
    owner = "onlyoffice";
    group = "onlyoffice";
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
  };
}
