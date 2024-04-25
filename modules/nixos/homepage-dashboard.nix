{config, ...}: let
  servicePort = 37999;
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
        Services = [
          {
            Paperless = [
              {
                abbr = "PL";
                href = "https://homelab.armadillo-snake.ts.net/paperless";
              }
            ];
          }
          {
            Nextcloud = [
              {
                abbr = "NC";
                href = "https://homelab.armadillo-snake.ts.net/nextcloud";
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

  services.nginx.virtualHosts."homepage.homelab.local"= {
    forceSSL = true;
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:${builtins.toString servicePort}";
    extraConfig = ''
      deny 192.168.178.1;
      allow 192.168.178.0/24;
      deny all;
    '';
  };};
}
