{config, ...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      caching.prefetching = true;
      caching.prefetchExpires = "12h";
      caching.cacheTimeNegative = "-1 min";
      log.level = "warn";
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        mapping = {
          "homelab.a4blue.me" = "192.168.178.64";
          "*.homelab.a4blue.me" = "192.168.178.64";
          "*.homelab.local" = "192.168.178.64";
          "homelab.local" = "192.168.178.64";
        };
      };
      upstreams.groups.default = [
        # Digital Courage
        "tcp-tls:dns3.digitalcourage.de:853"
        # Digitale Gesellschaft
        "https://dns.digitale-gesellschaft.ch/dns-query"
        # Uncensored DNS Anycast
        "https://anycast.uncensoreddns.org/dns-query"
        # Uncensored DNS Unicast
        "https://unicast.uncensoreddns.org/dns-query"
        # DNS Forge
        "https://dnsforge.de/dns-query"
        # Quad9 (Should i trust them ?)
        "https://dns.quad9.net/dns-query"
      ];
      bootstrapDns = [
        {
          upstream = "https://dns.digitale-gesellschaft.ch/dns-query";
          ips = ["2a05:fc84::42" "2a05:fc84::43" "185.95.218.42" "185.95.218.43"];
        }
        {
          upstream = "tcp-tls:dns3.digitalcourage.de:853";
          ips = ["5.9.164.112" "2a01:4f8:251:554::2"];
        }
        {
          upstream = "https://dns.quad9.net/dns-query";
          ips = ["9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9"];
        }
        {
          upstream = "https://anycast.uncensoreddns.org/dns-query";
          ips = ["91.239.100.100" "2001:67c:28a4::"];
        }
        {
          upstream = "https://unicast.uncensoreddns.org/dns-query";
          ips = ["89.233.43.71" "2a01:3a0:53:53::"];
        }
      ];
      blocking = {
        blackLists = {
          ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        };
        clientGroupsBlock = {
          default = ["ads"];
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
