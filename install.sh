# Perpare Partitions
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1025MiB
parted /dev/nvme0n1 -- set 1 boot on
parted /dev/nvme0n1 -- mkpart swap 1025MiB 21GiB
parted /dev/nvme0n1 -- mkpart Nix 21GiB 100%
# boot
mkfs.fat -F32 -n boot /dev/nvme0n1p1
# swap
mkswap -L swap /dev/nvme0n1p2
swapon -L swap
# bcachefs
bcachefs format --encrypt /dev/nvme0n1p3
bcachefs unlock -k session /dev/nvme0n1p3
# mount
mount /dev/nvme0n1p3 /mnt/
bcachefs subvolume create /mnt/persistent
mkdir -pv /mnt/{boot,nix,etc/ssh,var/{lib,log}}
mount /dev/disk/by-label/boot /mnt/boot/
mkdir -pv /mnt/{nix/secret/initrd,persistent/{etc/ssh,var/{lib,log}}}
mount -o bind /mnt/persistent/var/log /mnt/var/log
# initialisation
chmod 0700 /mnt/nix/secret
mkdir -pv /mnt/persistent/home/
chmod 0777 /mnt/persistent/home
# Generate SOPS Keys
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/initrd/ssh_host_ed25519_key
nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/nix/secret/initrd/ssh_host_ed25519_key.pub | ssh-to-age'
chmod 0755 /mnt/persistent/etc/ssh
# Generate sshd Keys
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_ed25519_key
ssh-keygen -t rsa -b 4096 -N "" -C "" -f /mnt/persistent/etc/ssh/ssh_host_rsa_key
# Generate Hetzner Storage Box Keys (for Borgbackup)
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/hetzner_storage_box/ssh_hetzner_storage_box_ed25519_key

#nixos-generate-config --root /mnt
#git clone https://github.com/a4blue/own-nix-os-config.git /home/nixos/own-nix-os-config
#nixos-install --no-root-passwd --root /mnt --flake /home/nixos/own-nix-os-config#homelab
#dd if=<path-to-image> of=/dev/sdX bs=4M conv=fsync