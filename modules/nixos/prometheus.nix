{
  config,
  pkgs,
  lib,
  ...
}: {
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = ["logind" "systemd"];
  };

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };
}
