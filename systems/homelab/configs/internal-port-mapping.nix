{config, ...}: {
  services.bazarr.listenPort = 65535;
  modules.dashdot.port = 65535 - 1;
  services.forgejo.settings.server.HTTP_PORT = 65535 - 2;
  services.grafana.settings.server.http_port = 65535 - 3;
  modules.homarr.port = 65535 - 4;
  services.keycloak.settings.http-port = 65535 - 5;
  modules.koillection.port = 65535 - 6;
  services.ombi.port = 65535 - 7;
  services.onlyoffice.port = 65535 - 8;
  services.sabnzbd.settings.misc.port = 65535 - 9;
  services.seerr.port = 65535 - 10;
  services.stash.settings.port = 65535 - 11;
  modules.unmanic.port = 65535 - 12;
}
