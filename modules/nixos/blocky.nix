{config, ...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      caching.prefetching = true;
      caching.prefetchExpires = "2h";
      caching.cacheTimeNegative = "1m";
      caching.minTime = "10m";

      queryLog.type = "csv";
      queryLog.target = "/var/lib/blocky";
      queryLog.logRetentionDays = 7;

      log.level = "warn";
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        mapping = {
          "fritz.box" = "192.168.178.1";
          "homelab.a4blue.me" = "192.168.178.64";
          "*.homelab.a4blue.me" = "192.168.178.64";
          "*.homelab.internal" = "192.168.178.64";
          "homelab.internal" = "192.168.178.64";
          "home.a4blue.me" = "192.168.178.64";
          "nextcloud.home.a4blue.me" = "192.168.178.64";
        };
      };
      upstreams.groups.default = [
        # https://digitalcourage.de/support/zensurfreier-dns-server
        # UnCensored ✅
        "tcp-tls:dns3.digitalcourage.de:853"
        # https://www.digitale-gesellschaft.ch/dns/
        # UnCensored ✅
        "https://dns.digitale-gesellschaft.ch/dns-query"
        # https://blog.uncensoreddns.org/dns-servers/
        # UnCensored ✅
        "https://anycast.uncensoreddns.org/dns-query"
        # https://blog.uncensoreddns.org/dns-servers/
        # UnCensored ✅
        "https://unicast.uncensoreddns.org/dns-query"
        # https://dnsforge.de/
        # Censored 🚫
        "https://dnsforge.de/dns-query"
        # https://quad9.net/de/service/service-addresses-and-features
        # Censored 🚫
        "https://dns.quad9.net/dns-query"
        # https://mullvad.net/de/help/dns-over-https-and-dns-over-tls
        # UnCensored ✅
        "https://dns.mullvad.net/dns-query"
        # https://blahdns.com/
        # Censored 🚫
        "https://doh-de.blahdns.com/dns-query"
        # https://dismail.de/info.html#dns
        # Censored 🚫
        "tcp-tls:fdns2.dismail.de:853"
        # https://dns.njal.la/
        # UnCensored ✅
        "https://dns.njal.la/dns-query"
        # https://opennameserver.org/
        # UnCensored ✅
        "https://ns.opennameserver.org/dns-query"
        # https://controld.com/free-dns
        # UnCensored ✅
        "https://freedns.controld.com/p0"
        # https://servers.opennic.org/edit.php?srv=ns2.de.dns.opennic.glue
        # UnCensored ✅
        "https://doh.kekew.info/dns-query"
        # https://servers.opennic.org/edit.php?srv=ns23.de.dns.opennic.glue
        # UnCensored ✅
        "https://dns3.opennic.probst.click/"
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
        {
          upstream = "https://dns.mullvad.net/dns-query";
          ips = ["194.242.2.2" "2a07:e340::2"];
        }
      ];
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
    };
  };
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/blocky";
        mode = "0777";
      }
    ];
  };
}
