{config, ...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      log.level = "warn";
      upstreams.groups.default = [
        # Owners:
        # opennameserver.org
        "tcp-tls:ns1.no.dns.opennic.glue"
        # sammefishe
        "tcp-tls:ns5.fi.dns.opennic.glue"
        # EricL
        "tcp-tls:ns1.fr.dns.opennic.glue"
        # mistersixt
        "tcp-tls:ns29.de.dns.opennic.glue"
        # probst.click
        "tcp-tls:ns26.de.dns.opennic.glue"
        # Koby
        "tcp-tls:ns3.de.dns.opennic.glue"
      ];
      bootstrapDns = [
        {
          upstream = "tcp-tls:dns.digitale-gesellschaft.ch:853";
          ips = ["2a05:fc84::42" "2a05:fc84::43" "185.95.218.42" "185.95.218.43"];
        }
        {
          upstream = "tcp-tls:dns3.digitalcourage.de:853";
          ips = ["5.9.164.112" "2a01:4f8:251:554::2"];
        }
        {
          upstream = "tcp-tls:dot1.applied-privacy.net:853";
          ips = ["146.255.56.98" "2a02:1b8:10:234::2"];
        }
      ];
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        mapping = {
          #"fritz.box" = "192.168.178.1";
          #"homelab.a4blue.me" = "192.168.178.64";
          #"*.homelab.a4blue.me" = "192.168.178.64";
          #"*.homelab.internal" = "192.168.178.64";
          #"homelab.internal" = "192.168.178.64";
          #"home.a4blue.me" = "192.168.178.64";
          #"nextcloud.home.a4blue.me" = "192.168.178.64";
        };
      };
      blocking = {
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://perflyst.github.io/PiHoleBlocklist/SmartTV.txt"
          ];
        };
        clientGroupsBlock = {
          default = ["ads"];
        };
      };
      caching = {
        prefetching = true;
        prefetchExpires = "2h";
        cacheTimeNegative = "1m";
        minTime = "10m";
      };

      #queryLog = {type = "console";};
    };
  };
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
