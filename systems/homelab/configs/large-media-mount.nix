{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  sops.secrets.large_media_password = {
    owner = "root";
    group = "root";
  };
  systemd.services."bcachefs-large-media-mount" = {
    after = ["local-fs.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      DEVICE_PATH = "/dev/disk/by-uuid/97c07ac6-f5d8-4ab2-8f8f-3b089416d8ed";
      MOUNT_POINT = "/LargeMedia";
    };
    script = ''
      #!${pkgs.runtimeShell} -e

      ${pkgs.keyutils}/bin/keyctl link @u @s

      # Check if the drive is already mounted
      if ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
        echo "Drive already mounted at $MOUNT_POINT. Skipping..."
        exit 0
      fi

      if [ ! -d "$MOUNT_POINT" ]; then
        mkdir $MOUNT_POINT
      fi

      sleep 5

      # Mount the device
      ${pkgs.bcachefs-tools}/bin/bcachefs mount -f ${config.sops.secrets.large_media_password.path} "$DEVICE_PATH" "$MOUNT_POINT"
      sleep 5
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  users.groups.LargeMediaUsers.members = ["a4blue"];
}
