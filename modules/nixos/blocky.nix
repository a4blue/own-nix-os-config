{config, ...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      caching.prefetching = true;
      caching.prefetchExpires = "12h";
      caching.cacheTimeNegative = "-1";
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        mapping = {
          "home-test.a4blue.me" = "192.168.178.64";
          "home.a4blue.me" = "192.168.178.64";
          "nextcloud.home.a4blue.me" = "192.168.178.64";
        };
      };
      upstreams.groups.default = [
        # Digital Courage
        "tcp-tls:2a01:4f8:251:554::2:853"
        # Digitale Gesellschaft
        "https://dns.digitale-gesellschaft.ch/dns-query"
        # Uncensored DNS Anycast
        "tcp-tls:2001:67c:28a4:::853"
      ];
      bootstrapDns = {
        upstream = "https://dns.digitale-gesellschaft.ch/dns-query";
        ips = ["2a05:fc84::42" "2a05:fc84::43" "185.95.218.42" "185.95.218.43"];
      };
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
