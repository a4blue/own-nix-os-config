{
  config,
  lib,
  pkgs,
  utils,
  ...
}: {
  systemd.services = {
    "recreate-root" = {
      description = "";
      requiredBy = ["sysroot-temp_root.mount"];
      after = ["unlock-bcachefs-temp_root.service"];
      before = [
        "sysroot-temp_root.mount"
        "shutdown.target"
      ];
      bindsTo = ["dev-nvme0n1p3.device"];
      conflicts = ["shutdown.target"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        #ExecCondition = "${pkgs.bcachefs-tools}/bin/bcachefs unlock -c \"/dev/nvme0n1p3\"";
        Restart = "on-failure";
        RestartMode = "direct";
        # Ideally, this service would lock the key on stop.
        # As is, RemainAfterExit doesn't accomplish anything.
        RemainAfterExit = true;
      };
      script = ''
        mkdir /bcachefs_recreate_root
        mount /dev/nvme0n1p3 /bcachefs_recreate_root
        if [[ -e /bcachefs_recreate_root/root ]]; then
          ${pkgs.bcachefs-tools}/bin/bcachefs subvolume delete /bcachefs_recreate_root/root
        fi
        ${pkgs.bcachefs-tools}/bin/bcachefs subvolume create /bcachefs_recreate_root/root
        umount /bcachefs_recreate_root
        rm -R /bcachefs_recreate_root
      '';
    };
  };
}
