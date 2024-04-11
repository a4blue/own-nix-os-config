{
  config,
  lib,
  pkgs,
  utils,
  ...
}: {
  services.udev.packages = with pkgs; [gnugrep findutils];
  systemd.packages = with pkgs; [gnugrep findutils];
  #boot.initrd.systemd.extraBin = {
    #"find" = "${pkgs.gnugrep}/bin/find";
  #};
  boot.initrd.systemd.packages = with pkgs; [gnugrep findutils];
  boot.initrd.systemd.services = {
    "recreate-root" = {
      description = "";
      requiredBy = ["initrd-nixos-activation.service"];
      after = ["sysroot.mount"];
      before = [
        "initrd-nixos-activation.service"
        "initrd-switch-root.target"
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
        RemainAfterExit = true;
      };
      script = ''
        find /sysroot -maxdepth 1 | grep -v "/sysroot/nix\|/sysroot/persistent\|^/sysroot$" | xargs rm -rf
      '';
    };
  };
}
