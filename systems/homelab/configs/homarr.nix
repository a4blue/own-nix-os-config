{config, ...}: let
  serviceDomain = "start.home.a4blue.me";
  servicePort = 7577;
in {
  virtualisation.oci-containers.containers = {
    homarr = {
      image = "ghcr.io/homarr-labs/homarr:latest";
      autoStart = true;
      ports = ["127.0.0.1:${builtins.toString servicePort}:7575"];
      volumes = ["/var/lib/homarr/appdata:/appdata"];
      environmentFiles = [config.sops.secrets."homarrEnv".path];
      environment = {
        AUTH_PROVIDERS = "oidc";
        AUTH_OIDC_ISSUER = "https://auth.home.a4blue.me/realms/main";
        AUTH_OIDC_CLIENT_ID = "start.home.a4blue.me";
        AUTH_OIDC_CLIENT_NAME = "Keycloak";
        AUTH_OIDC_AUTO_LOGIN = "true";
        AUTH_OIDC_GROUPS_ATTRIBUTE = "groups";
        AUTH_OIDC_SCOPE_OVERWRITE = "openid microprofile-jwt";
      };
    };
  };
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/homarr";
        mode = "0777";
        user = "nobody";
        group = "nogroup";
      }
      {
        directory = "/var/lib/containers";
        mode = "0777";
        user = "root";
        group = "root";
      }
    ];
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
    };
    locations."/websockets" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
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
