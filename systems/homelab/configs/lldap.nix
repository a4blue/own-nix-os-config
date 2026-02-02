{config, ...}: let
  serviceDomain = "ldap.home.a4blue.me";
  servicePort = 17170;
in {
  sops.secrets = {
    "lldap/userPassword" = {
      owner = "lldap";
      group = "lldap";
    };
    "lldap/jwtSecret" = {
      owner = "lldap";
      group = "lldap";
    };
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
      # I dont know if this should be secret or not
      # See https://github.com/lldap/lldap/blob/main/lldap_config.docker_template.toml#L108
      # It claims that even with that knowledge its pretty hard to crack
      key_seed = "b7e7e121e2f549b63362d5fd104a6f0fb46ba40ed98e20f1d3e6831889d30f421f367dedfb656333b22724d8187860eecb7fea578e98d4c1e315c09c1b62147f";
    };
    database = {
      type = "postgresql";
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
}
