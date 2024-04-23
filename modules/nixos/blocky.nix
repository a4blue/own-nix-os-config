{config, ...}: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
      customDNS = {
        customTTL = "1h";
        filterUnmappedTypes = "true";
        mapping = {
          home.a4blue.me = "192.168.178.64";
          nextclod.home.a4blue.me = "192.168.178.64";
        };
      };
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
      ];
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = ["1.1.1.1" "1.0.0.1"];
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
