{config, ...}: {
  ####
  # Main Config
  ####
  services.blocky = {
    enable = true;
    enableConfigCheck = true;
    settings = {
      prometheus.enable = true;
      prometheus.path = "/metrics";
      ports.dns = 53;
      ports.tls = 853;
      ports.http = 4000;
      certFile = "/nix/secret/blocky_cert/blocky.crt";
      keyFile = "/nix/secret/blocky_cert/blocky.key";
      log.level = "warn";
      upstreams.groups.default = [
        "https://opennic.i2pd.xyz/dns-query" # ns8.fr
        "tcp-tls:ns5.fi.dns.opennic.glue#dns.froth.zone" # sammefishe
        "https://korridor.semia-infra.net/dns-query" # ns2.at
        "tcp-tls:ns2.de.dns.opennic.glue:65533#kekew.info"
        "tcp-tls:ns3.de.dns.opennic.glue#dns.furrytech.io"
        "tcp-tls:ns29.de.dns.opennic.glue#morbitzer.de"
        "https://opennic2.eth-services.de:853" # ns31.de
        "https://ns1.opennameserver.org/dns-query"
        "https://ns4.opennameserver.org/dns-query"
      ];
      bootstrapDns = [
        {
          upstream = "tcp-tls:ns4.de.dns.opennic.glue:65533#kekew.info";
          ips = ["80.153.146.105" "2003:a:812:5700::6"];
        }
        {
          upstream = "tcp-tls:ns8.fr.dns.opennic.glue#opennic.i2pd.xyz";
          ips = ["91.190.185.43" "2001:470:1f15:b80::53"];
        }
        {
          upstream = "tcp-tls:ns4.pl.dns.opennic.glue#opennic2.i2pd.xyz";
          ips = ["185.226.181.19" "2001:470:71:6dc::53"];
        }
      ];
      customDNS = {
        customTTL = "5m";
        filterUnmappedTypes = true;
        rewrite = {
          "home" = "internal";
          "lan" = "internal";
        };
        mapping = {
          "fritz.box" = "192.168.178.1";
          "homelab.internal" = "192.168.178.65";
          "home.a4blue.me" = "192.168.178.65";
        };
      };
      blocking = {
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://perflyst.github.io/PiHoleBlocklist/SmartTV.txt"
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.txt"
            "https://perflyst.github.io/PiHoleBlocklist/AmazonFireTV.txt"
            "https://perflyst.github.io/PiHoleBlocklist/SessionReplay.txt"
            "https://perflyst.github.io/PiHoleBlocklist/android-tracking.txt"
          ];
        };
        clientGroupsBlock = {
          default = ["ads"];
        };
        loading = {
          maxErrorsPerSource = -1;
          downloads = {
            attempts = 10;
            cooldown = "5m";
          };
        };
      };
      caching = {
        prefetching = true;
        prefetchExpires = "2h";
        cacheTimeNegative = "1m";
        minTime = "10m";
      };
    };
  };
  ####
  # Firewall
  ####
  networking.firewall.allowedTCPPorts = [config.services.blocky.settings.ports.dns config.services.blocky.settings.ports.tls];
  networking.firewall.allowedUDPPorts = [config.services.blocky.settings.ports.dns config.services.blocky.settings.ports.tls];
  ####
  # Prometheus
  ####
  services.prometheus.scrapeConfigs = [
    {
      job_name = "blocky";
      static_configs = [
        {
          targets = [
            "localhost:${toString config.services.blocky.settings.ports.http}"
          ];
        }
      ];
    }
  ];
}
