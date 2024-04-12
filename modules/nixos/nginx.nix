{config, ...}: {
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "a4blue@hotmail.de";
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enable = true;
    tailscaleAuth.enable = true;
    virtualHosts = {
      "home.a4blue.me" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
        };
      };
      "homelab.armadillo-snake.ts.net" = {
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://localhost:3000";
        };
        locations."/paperless" = {
          recommendedProxySettings = true;
          proxyPass = "http://localhost:28981";
        };
        locations."^~ /.well-known" = {
          priority = 9000;
          extraConfig = ''
            absolute_redirect off;
            location ~ ^/\\.well-known/(?:carddav|caldav)$ {
              return 301 /nextcloud/remote.php/dav;
            }
            location ~ ^/\\.well-known/host-meta(?:\\.json)?$ {
              return 301 /nextcloud/public.php?service=host-meta-json;
            }
            location ~ ^/\\.well-known/(?!acme-challenge|pki-validation) {
              return 301 /nextcloud/index.php$request_uri;
            }
            try_files $uri $uri/ =404;
          '';
        };
        locations."/nextcloud/" = {
          priority = 9999;
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-NginX-Proxy true;
            proxy_set_header X-Forwarded-Proto http;
            proxy_pass http://localhost:8080/; # tailing / is important!
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            proxy_redirect off;
          '';
        };
        sslCertificate = "/var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.crt";
        sslCertificateKey = "/var/lib/tailscale-nginx-certs/homelab.armadillo-snake.ts.net.key";
      };
      "_" = {
        globalRedirect = "home.a4blue.de";
        default = true;
      };
    };
    tailscaleAuth.virtualHosts = ["homelab.armadillo-snake.ts.net"];
  };
  users.users.nginx.extraGroups = ["acme"];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/acme"
    ];
  };
}
