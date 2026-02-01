{config, ...}: let
  serviceDomain = "ldap.home.a4blue.me";
  servicePort = 17170;
in {
  sops.secrets."lldap/userPassword" = {
    owner = "lldap";
    group = "lldap";
  };
  sops.secrets."lldap/jwtSecret" = {
    owner = "lldap";
    group = "lldap";
  };
  services.lldap = {
    enable = true;
    settings = {
      http_url = "https://${serviceDomain}";
      http_host = "127.0.0.1";
      http_port = servicePort;

      ldap_host = "127.0.0.1";
      ldap_port = 3890;
      ldap_base_dn = "dc=home.a4blue,dc=me";

      ldap_user_pass_file = config.sops.secrets."lldap/userPassword".path;
      force_ldap_user_pass_reset = "always";
      jwt_secret_file = config.sops.secrets."lldap/jwtSecret".path;
      database_url = "sqlite:///var/lib/lldap/users.db?mode=rwc";
    };
  };
  users.users.lldap = {
    name = "lldap";
    group = "lldap";
    isSystemUser = true;
  };
  users.groups.lldap = {};
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    extraConfig = ''
      client_max_body_size 20M;
      add_header X-Content-Type-Options "nosniff";
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header Host $host;
        allow 192.168.178.1/24;
        deny all;
      '';
    };
  };

  # TODO make it persistent
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/lldap";
        mode = "0740";
        user = "lldap";
        group = "lldap";
      }
    ];
  };
}
