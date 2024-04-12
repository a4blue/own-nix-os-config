{
  config,
  pkgs,
  lib,
  ...
}: {
  config.services.homepage-dashboard = {
    enable = true;
    listenPort = 3000;
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
}
