{config, ...}: {
  ####
  # Main Config
  ####
  services.prometheus = {
    enable = false;
    globalConfig.scrape_interval = "1m";
    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "logind"
          "systemd"
        ];
        disabledCollectors = ["textfile"];
      };
      systemd = {enable = true;};
      fritzbox = {
        enable = true;
        gatewayAddress = "192.168.178.1";
      };
    };
  };
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/${config.services.prometheus.stateDir}";
        mode = "0740";
        user = "ombi";
        group = "ombi";
      }
    ];
  };
}
