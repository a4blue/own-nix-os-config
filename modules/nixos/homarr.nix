{
  config,
  lib,
  ...
}: let
  cfg = config.modules.homarr;
in {
  options.modules.homarr = {
    enable = lib.mkEnableOption "Homarr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      homarr = {
        image = "ghcr.io/homarr-labs/homarr:latest";
        autoStart = true;
        ports = ["127.0.0.1:${builtins.toString cfg.port}:7575"];
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
  };
}
