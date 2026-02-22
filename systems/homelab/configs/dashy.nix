{config, ...}: {
  services.dashy = {
    enable = true;
    virtualHost.domain = "start.home.a4blue.me";
    virtualHost.enableNginx = true;
    settings = {
      appConfig = {
        enableFontAwesome = true;
        auth = {
          enableGuestAccess = false;
          enableOidc = true;
          oidc = {
            clientId = "start.home.a4blue.me";
            endpoint = "https://auth.home.a4blue.me/realms/main";
            scope = "openid email profile";
            adminGroup = "admin";
          };

          #enableKeycloak = true;
          #keycloak = {
          #  serverUrl = "https://auth.home.a4blue.me";
          #  realm = "main";
          #  clientId = "start.home.a4blue.me";
          #};
        };
        #disableConfigurationForNonAdmin = true;
      };
      sections = [
        {
          name = "Home Services";
          items = [
            {
              title = "Streaming";
              description = "Stream media with Jellyfin";
              url = "https://jellyfin.home.a4blue.me";
              target = "newtab";
            }
            {
              title = "Cloud";
              description = "Nextcloud Server";
              url = "https://nextcloud.home.a4blue.me";
              target = "newtab";
            }
            {
              title = "Account";
              description = "Manage Account Data";
              url = "https://auth.home.a4blue.me/realms/main/account/";
              target = "newtab";
            }
            {
              title = "Media Request";
              description = "Request new Media";
              url = "https://ombi.home.a4blue.me";
              target = "newtab";
            }
          ];
        }
      ];
    };
  };
  services.nginx.virtualHosts."${config.services.dashy.virtualHost.domain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
  };
}
