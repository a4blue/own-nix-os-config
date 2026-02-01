{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "auth.home.a4blue.me";
  servicePort = 9933;
in {
  sops.secrets = {
    "authelia/jwtSecret" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/storageEncryptionKey" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/sessionSecret" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/oidcHmacSecret" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/authBackendLDAPPassword" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/smtpPassword" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/oidcPrivateKey" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
    };
    "authelia/lldap/jwtSecret" = {
      owner = "authelia-auth.home.a4blue.me";
      group = "authelia-auth.home.a4blue.me";
      key = "lldap/jwtSecret";
    };
  };
  services.authelia.instances.${serviceDomain} = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
      sessionSecretFile = config.sops.secrets."authelia/sessionSecret".path;
      oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidcPrivateKey".path;
      oidcHmacSecretFile = config.sops.secrets."authelia/oidcHmacSecret".path;
    };
    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.sops.secrets."authelia/lldap/jwtSecret".path;
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.sops.secrets."authelia/smtpPassword".path;
      X_AUTHELIA_CONFIG_FILTERS = "template";
    };
    settings = {
      server.address = "tcp://127.0.0.1:${builtins.toString servicePort}";

      # First Factor / User Storage
      authentication_backend = {
        refresh_interval = "5m";
        password_reset.disable = "false";
        password_change.disable = "false";
        ldap = {
          implementation = "lldap";
          address = "ldap://127.0.0.1:3890";
          timeout = "5s";
          start_tls = "false";
          base_dn = "${config.services.lldap.settings.ldap_base_dn}";
          user = "uid=admin,ou=people,${config.services.lldap.settings.ldap_base_dn}";
        };
      };
      # Second Factor
      totp = {
        disable = "false";
        issuer = "${serviceDomain}";
        algorithm = "sha512";
        digits = "6";
        period = "30";
        skew = "1";
        secret_size = "32";
      };
      webauthn = {
        disable = "false";
        enable_passkey_login = "true";
        display_name = "${serviceDomain}";
      };
      # Security
      access_control = {
        default_policy = "deny";
        networks = [
          {
            name = "internal";
            networks = [
              "10.0.0.0/8"
              "172.16.0.0/12"
              "192.168.0.0/18"
            ];
          }
        ];
        rules = [
          {
            domain = "${serviceDomain}";
            policy = "bypass";
            resources = [
              "^/api/.*"
            ];
          }
        ];
      };
      password_policy = {
        zxcvbn = {
          enabled = "true";
          min_score = "2";
        };
      };
      identity_validation = {
        reset_password = {
          jwt_lifespan = "60 minutes";
          jwt_algorithm = "HS512";
        };
      };
      session = {
        name = "a4blue_authelia_session";
        cookies = [
          {
            domain = "home.a4blue.me";
            authelia_url = "https://${serviceDomain}";
          }
        ];
        same_site = "lax";
        expiration = "1h";
        inactivity = "5m";
        remember_me = "1M";
        redis = {
          host = config.services.redis.servers.authelia.unixSocket;
          port = 0;
        };
      };
      storage = {
        postgres = {
          address = "unix:///run/postgresql";
          username = config.services.authelia.instances.${serviceDomain}.user;
          database = config.services.authelia.instances.${serviceDomain}.user;
          password = "test";
        };
      };
      notifier = {
        smtp = {
          address = "smtp://smtp.protonmail.ch:587";
          username = "homelab@a4blue.me";
          sender = "a4blue Homeserver <homelab@a4blue.me>";
          subject = "[Authelia] {title}";
          startup_check_address = "test@authelia.com";
        };
      };
      identity_providers.oidc = {
        claims_policies = {
          # Default needed for Startup
          default.id_token = [
            "email"
            "preferred_username"
            "name"
            "groups"
          ];
        };
        clients = [
          {
            client_id = "example_id";
            claims_policy = "default";
            client_secret = "{{ secret \"${pkgs.writeText "example.secret" "example_client_secret"}\" }}";
            client_name = "Example Client to Start Authelia";
            public = false;
            authorization_policy = "one_factor";
            redirect_uris = [];
          }
        ];
      };
    };
  };
  services.redis.servers.authelia = {
    enable = true;
    user = config.services.authelia.instances.${serviceDomain}.user;
  };

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/authelia";
        mode = "0740";
        user = config.services.authelia.instances.${serviceDomain}.user;
        group = config.services.authelia.instances.${serviceDomain}.group;
      }
      {
        directory = "/var/lib/redis-authelia";
        mode = "0740";
        user = config.services.authelia.instances.${serviceDomain}.user;
        group = config.services.authelia.instances.${serviceDomain}.group;
      }
    ];
  };

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
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
      '';
    };
    locations."/api/verify" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
      '';
    };
  };
}
