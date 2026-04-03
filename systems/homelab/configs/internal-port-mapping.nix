{config, ...}: {
  services = {
    bazarr.listenPort = 65535;
    forgejo.settings.server.HTTP_PORT = 65535 - 1;
    grafana.settings.server.http_port = 65535 - 2;
    keycloak.settings.http-port = 65535 - 3;
    ombi.port = 65535 - 4;
    onlyoffice.port = 65535 - 5;
    sabnzbd.settings.misc.port = 65535 - 6;
    seerr.port = 65535 - 7;
    stash.settings.port = 65535 - 8;
  };
  modules = {
    dashdot.port = 65535 - 9;
    homarr.port = 65535 - 10;
    koillection.port = 65535 - 11;
    unmanic.port = 65535 - 12;
  };
}
