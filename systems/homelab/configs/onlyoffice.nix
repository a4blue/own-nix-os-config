{config, ...}: {
  services.onlyoffice = {
    enable = true;
    wopi = true;
    hostname = "localhost";
    securityNonceFile = config.sops.secrets."onlyoffice/Nonce".path;
    jwtSecretFile = config.sops.secrets."onlyoffice/jwtSecretFile".path;
  };
  sops.secrets."onlyoffice/Nonce" = {
    owner = "onlyoffice";
    group = "onlyoffice";
  };
  sops.secrets."onlyoffice/jwtSecretFile" = {
    owner = "onlyoffice";
    group = "onlyoffice";
  };
}
