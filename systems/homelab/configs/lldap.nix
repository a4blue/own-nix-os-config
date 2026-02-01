{config, ...}: {
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
      #http_url = "https://${fqdn}";
      http_host = "127.0.0.1";
      http_port = 17170;

      ldap_host = "127.0.0.1";
      ldap_port = 3890;
      ldap_base_dn = "dc=home.a4blue,dc=me";

      ldap_user_pass_file = config.sops.secrets."lldap/userPassword".path;
      force_ldap_user_pass_reset = "always";
      jwt_secret_file = config.sops.secrets."lldap/jwtSecret".path;
    };
  };
  users.users.lldap = {
    name = "lldap";
    group = "lldap";
    isSystemUser = true;
  };
  users.groups.lldap = {};
}
