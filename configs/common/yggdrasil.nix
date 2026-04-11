{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.services.yggdrasil.enable {
  services.yggdrasil = {
    persistentKeys = true;
    openMulticastPort = true;
    settings = {
      Peers = [
        "quic://ygg1.mk16.de:1339?key=0000000087ee9949eeab56bd430ee8f324cad55abf3993ed9b9be63ce693e18a"
        "quic://ygg2.mk16.de:1339?key=000000d80a2d7b3126ea65c8c08fc751088c491a5cdd47eff11c86fa1e4644ae"
        "quic://ygg7.mk16.de:1339?key=000000086278b5f3ba1eb63acb5b7f6e406f04ce83990dee9c07f49011e375ae"
        "tcp://ip6.fvm.mywire.org:8080?key=000000000143db657d1d6f80b5066dd109a4cb31f7dc6cb5d56050fffb014217"
        "tls://yggdrasil.neilalexander.dev:64648?key=ecbbcb3298e7d3b4196103333c3e839cfe47a6ca47602b94a6d596683f6bb358"
      ];
    };
  };
  systemd.services.yggdrasil = {
    serviceConfig = {
      PrivateMounts = lib.mkForce false;
    };
  };
  environment =
    if config.modules.impermanenceExtra.enabled
    then {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          {
            directory = "/var/lib/private/yggdrasil";
            mode = "0755";
            user = "nobody";
            group = "nogroup";
          }
        ];
      };
    }
    else {};
}
