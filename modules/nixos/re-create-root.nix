{
  config,
  lib,
  pkgs,
  utils,
  ...
}: {
  boot.initrd.systemd.packages = with pkgs; [gnugrep findutils];
  boot.initrd.systemd.services = {
    "recreate-root" = {
      description = "";
      requiredBy = ["sysroot.mount"];
      after = ["dev-nvme0n1p3.device"];
      before = [
        "sysroot.mount"
        "shutdown.target"
      ];
      bindsTo = ["dev-nvme0n1p3.device"];
      conflicts = ["shutdown.target"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecCondition = "${pkgs.bcachefs-tools}/bin/bcachefs unlock -c \"/dev/nvme0n1p3\"";
        Restart = "on-failure";
        RestartMode = "direct";
        # Ideally, this service would lock the key on stop.
        # As is, RemainAfterExit doesn't accomplish anything.
        RemainAfterExit = true;
      };
      script = ''
        ${config.boot.initrd.systemd.package}/bin/systemd-ask-password --timeout=0 "enter passphrase for / (poor man's impermanence)" | exec ${pkgs.bcachefs-tools}/bin/bcachefs unlock "/dev/nvme0n1p3"
        mkdir /bcachefs_recreate_root
        mount /dev/nvme0n1p3 /bcachefs_recreate_root
        find /bcachefs_recreate_root -maxdepth 1 | grep -v "/bcachefs_recreate_root/nix\|/bcachefs_recreate_root/persistent\|^/bcachefs_recreate_root$" | xargs rm -rf
        umount /bcachefs_recreate_root
        rm -R /bcachefs_recreate_root
      '';
    };
  };
}
