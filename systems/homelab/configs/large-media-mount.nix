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
      DEVICE_PATH = "/dev/disk/by-partlabel/LargeMedia01";
      MOUNT_POINT = "/LargeMedia";
    };
    script = ''
      #!${pkgs.runtimeShell} -e

      ${pkgs.keyutils}/bin/keyctl link @u @s

      # Check if the device path exists
      if [ ! -b "$DEVICE_PATH" ]; then
        echo "Error: Device path $DEVICE_PATH does not exist."
        exit 1
      fi

      # Check if the drive is already mounted
      if ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
        echo "Drive already mounted at $MOUNT_POINT. Skipping..."
        exit 0
      fi

      # Due to the large array it could take some time
      sleep 15
      # Wait for the device to become available
      while [ ! -b "$DEVICE_PATH" ]; do
        echo "Waiting for $DEVICE_PATH to become available..."
        sleep 5
      done

      # Mount the device
      ${pkgs.bcachefs-tools}/bin/bcachefs mount -f ${config.sops.secrets.large_media_password.path} "$DEVICE_PATH" "$MOUNT_POINT"
      sleep 5
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
