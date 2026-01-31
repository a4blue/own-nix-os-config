{config, ...}: {
  sops.secrets.lldap_ldapUserPassword = {};
  services.lldap = {
    enable = true;
    settings = {
      #http_url = "https://${fqdn}";
      http_host = "127.0.0.1";
      http_port = 17170;

      ldap_host = "127.0.0.1";
      ldap_port = 3890;
      ldap_base_dn = "dc=home.a4blue,dc=me";

      ldap_user_pass_file = config.sops.secrets.lldap_ldapUserPassword.path;
      force_ldap_user_pass_reset = "always";
      jwt_secret_file = "d34ffac7fa9af00f017a4f2e298aa4df766c2c8fa88bcfdc89bea676c8bfe56646b3fe0d9ae35fb5a367ffaf641f07500c50f1d81d5aab4106599dd35e6a5049";
    };
  };
  users.users.lldap = {
    name = "lldap";
    group = "lldap";
    isSystemUser = true;
  };
  users.groups.lldap = {};
}
