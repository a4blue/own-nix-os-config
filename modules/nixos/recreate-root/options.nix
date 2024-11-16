{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.recreate-root;
in {
  options.modules.recreate-root = {
    enable = lib.mkEnableOption "recreate root for filesystems";
    systemd-device-bind = lib.mkOption {type = lib.types.str;};
  };
  config = mkIf cfg.enable {
    services.udev.packages = [pkgs.findutils];
    systemd.packages = [pkgs.findutils];
    boot.initrd.systemd = {
      enable = true;
      extraBin = {
        "xargs" = "${pkgs.findutils}/bin/xargs";
        "find" = "${pkgs.findutils}/bin/find";
      };

      packages = [pkgs.findutils];
      services = {
        "recreate-root" = {
          description = "Deletes everything in rootfs except nix and persistent";
          requiredBy = [];
          after = ["sysroot.mount"];
          before = [
            "initrd-nixos-activation.service"
            "initrd-switch-root.service"
            "initrd-find-nixos-closure.service"
            "shutdown.target"
          ];
          # TODO
          # Is it needed ?
          #bindsTo = ["${cfg.systemd-device-bind}"];
          conflicts = ["shutdown.target"];
          unitConfig.DefaultDependencies = false;
          serviceConfig = {
            Type = "oneshot";
            Restart = "on-failure";
            RestartMode = "direct";
            RemainAfterExit = true;
          };
          # TODO
          # making it extensible would probably be great
          script = ''
            find /sysroot -maxdepth 1 -not -wholename "/sysroot/nix" -and -not -wholename "/sysroot/persistent" -and -not -wholename "/sysroot" -and -not -wholename "/sysroot/var" | xargs rm -rf
            # /sysroot/var/log is already mounted, why ?
            find /sysroot/var -maxdepth 1 -not -wholename "/sysroot/var/log" -and -not -wholename "/sysroot/var/empty" -and -not -wholename "/sysroot/var/lib/nixos" -and -not -wholename "/sysroot/var" -and -not -wholename "/sysroot/var/lib" | xargs rm -rf
          '';
        };
      };
    };
  };
}
