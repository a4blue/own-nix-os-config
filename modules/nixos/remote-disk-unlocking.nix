{
  config,
  lib,
  ...
}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.users.root.shell = "/bin/cryptsetup-askpass";
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.a4blue.openssh.authorizedKeys.keys;
      hostKeys = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
  };

  #boot.initrd.luks.devices.cryptroot.postOpenCommands = lib.mkAfter ''
  #  mkdir /btrfs_tmp
  #  mount /dev/HomelabNvmeGroup/nix /btrfs_tmp
  #  if [[ -e /btrfs_tmp/root ]]; then
  #      mkdir -p /btrfs_tmp/old_roots
  #      timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
  #      mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
  #  fi
  #
  #      delete_subvolume_recursively() {
  #          IFS=$'\n'
  #          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
  #              delete_subvolume_recursively "/btrfs_tmp/$i"
  #          done
  #          btrfs subvolume delete "$1"
  #      }
  #
  #      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
  #          delete_subvolume_recursively "$i"
  #      done
  #
  #      btrfs subvolume create /btrfs_tmp/root
  #      umount /btrfs_tmp
  #    '';
}
