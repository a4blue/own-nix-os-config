parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GB
parted /dev/nvme0n1 -- set 1 boot on
parted /dev/nvme0n1 -- mkpart Nix 1GB 100%
cryptsetup -q -v luksFormat /dev/nvme0n1p2
cryptsetup -q -v open /dev/nvme0n1p2 cryptroot
pvcreate /dev/mapper/cryptroot
vgcreate HomelabNvmeGroup /dev/mapper/cryptroot
lvcreate -L 20G HomelabNvmeGroup -n swap
lvcreate -l 100%FREE HomelabNvmeGroup -n nix
lvreduce -L -256M HomelabNvmeGroup/nix
mkfs.btrfs /dev/HomelabNvmeGroup/nix
mkswap /dev/HomelabNvmeGroup/swap

# Experimental
mkdir /btrfs_tmp
mount /dev/HomelabNvmeGroup/nix /btrfs_tmp/
btrfs subvolume create /btrfs_tmp/root
btrfs subvolume create /btrfs_tmp/nix
btrfs subvolume create /btrfs_tmp/persistent
mount -o subvol=root /dev/HomelabNvmeGroup/nix /mnt
mkdir -pv /mnt/{boot,nix,persistent,etc/ssh,var/{lib,log}}
mount /dev/disk/by-label/boot /mnt/boot
mount -o subvol=nix /dev/HomelabNvmeGroup/nix /mnt/nix/
mount -o subvol=persistent /dev/HomelabNvmeGroup/nix /mnt/persistent/
mkdir -pv /mnt/{nix/secret/initrd,persistent/{etc/ssh,var/{lib,log}}}
chmod 0700 /mnt/nix/secret
mount -o bind /mnt/persistent/var/log /mnt/var/log
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/initrd/ssh_host_ed25519_key
nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/nix/secret/initrd/ssh_host_ed25519_key.pub | ssh-to-age'
chmod 0700 /mnt/persistent/etc/ssh
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_ed25519_key
ssh-keygen -t rsa -b 4096 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_rsa_key

nixos-install --no-root-passwd --root /mnt --flake /home/nixos/own-nix-os-config#homelab