{config, ...}: let
  servicePort = 37999;
  serviceDomain = "homepage.homelab.internal";
in {
  imports = [
    ./nginx.nix
  ];
  services.homepage-dashboard = {
    enable = true;
    listenPort = servicePort;
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
          cputemp = true;
          uptime = true;
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];
    services = [
      {
        "Monitoring" = [
          {
            "FritzBox" = {
              description = "Fritz";
              widget = {
                type = "fritzbox";
                url = "http://192.168.178.1";
                fields = ["connectionStatus" "uptime" "maxDown" "maxUp"];
              };
            };
          }
        ];
      }
    ];
    bookmarks = [
      {
        "Local Services" = [
          {
            Paperless = [
              {
                abbr = "PL";
                href = "https://paperless.homelab.internal";
              }
            ];
          }
          {
            Forgejo = [
              {
                abbr = "FG";
                href = "https://forgejo.homelab.internal";
              }
            ];
          }
          {
            Jellyfin = [
              {
                abbr = "JF";
                href = "https://jellyfin.homelab.internal";
              }
            ];
          }
        ];
      }
      {
        "Public Services" = [
          {
            Nextcloud = [
              {
                abbr = "NC";
                href = "https://nextcloud.home.a4blue.me";
              }
            ];
          }
        ];
      }
      {
        Developer = [
          {
            Github = [
              {
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
        ];
      }
      {
        Entertainment = [
          {
            YouTube = [
              {
                abbr = "YT";
                href = "https://youtube.com/";
              }
            ];
          }
        ];
      }
    ];
  };

  services.nginx.virtualHosts."${serviceDomain}" = {
    #forceSSL = true;
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    extraConfig = ''
      ssl_stapling off;
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}";
      extraConfig = ''
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
      '';
    };
  };
}
