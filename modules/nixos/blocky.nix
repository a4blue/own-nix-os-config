{config, ...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      log.level = "warn";
      upstreams.groups.default = [
        # Owners:
        #"tcp-tls:ns26.de.dns.opennic.glue" # probst.click, cert is expired
        "tcp-tls:ns1.fr.dns.opennic.glue#dns.elanceleur.org" # EricL
        "tcp-tls:ns1.no.dns.opennic.glue#ns4.opennameserver.org" # opennameserver.org
        "tcp-tls:ns5.fi.dns.opennic.glue#dns.froth.zone" # sammefishe
        "tcp-tls:ns3.de.dns.opennic.glue#dns.furrydns.de" # Koby
        "tcp-tls:ns13.de.dns.opennic.glue#ns1.opennameserver.org" # opennameserver.org
        "tcp-tls:ns16.de.dns.opennic.glue#ns2.opennameserver.org" # opennameserver.org
        "tcp-tls:ns18.de.dns.opennic.glue#ns3.opennameserver.org" # opennameserver.org
        "tcp-tls:ns23.de.dns.opennic.glue#dns3.opennic.probst.click" # probst.click
        "tcp-tls:ns28.de.dns.opennic.glue#jabber-germany.de" # mistersixt
        "tcp-tls:ns29.de.dns.opennic.glue#morbitzer.de" # mistersixt
      ];
      bootstrapDns = [
        {
          upstream = "tcp-tls:ns2.de.dns.opennic.glue:853#kekew.info";
          ips = ["80.152.203.134" "2003:a:64b:3b00::2"];
        }
        {
          upstream = "tcp-tls:ns28.de.dns.opennic.glue:853#jabber-germany.de";
          ips = ["152.53.15.127" "2a03:4000:006b:0191:9825:1cff:fe34:0bbe"];
        }
      ];
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = true;
        mapping = {
          "fritz.box" = "192.168.178.1";
          "*.fritz.box" = "192.168.178.1";
          "*.homelab.internal" = "192.168.178.64";
          "forgejo.homelab.internal" = "192.168.178.64";
          #"homelab.a4blue.me" = "192.168.178.64";
          #"*.homelab.a4blue.me" = "192.168.178.64";
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
