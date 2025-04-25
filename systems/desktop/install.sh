# Prepare Partitions
parted /dev/nvme1n1 -- mklabel gpt
parted /dev/nvme1n1 -- mkpart ESP fat32 1MiB 2049MiB
parted /dev/nvme1n1 -- set 1 boot on
parted /dev/nvme1n1 -- mkpart swap 2049MiB 34GiB
parted /dev/nvme1n1 -- mkpart Nix 34GiB 512GiB
parted /dev/nvme1n1 -- mkpart Games 512GiB 100%
# boot
mkfs.fat -F32 -n boot /dev/nvme1n1p1
# swap
mkswap -L swap /dev/nvme1n1p2
swapon -L swap
# bcachefs
bcachefs format --encrypt /dev/nvme1n1p3
bcachefs unlock -k session /dev/nvme1n1p3

bcachefs format /dev/nvme1n1p3
# mount
mount -t tmpfs none /mnt
mkdir -pv /mnt/{boot,nix,Games}
mount /dev/nvme0n1p3 /mnt/nix/
mount /dev/disk/by-label/boot /mnt/boot/
mount /dev/disk/by-label/Games /mnt/Games/
bcachefs subvolume create /mnt/nix/persistent
bcachefs subvolume create /mnt/nix/persistent/tmp
mkdir /mnt/nix/persistent/var
bcachefs subvolume create /mnt/nix/persistent/var/tmp
bcachefs subvolume create /mnt/nix/persistent/var/cache

bcachefs subvolume create /mnt/nix/persistent/var/log
bcachefs subvolume create /mnt/nix/persistent/var/lib

mkdir /mnt/nix/persistent/home
bcachefs subvolume create /mnt/nix/persistent/home/a4blue

mkdir -pv /mnt/var/log
mount -o bind /mnt/nix/persistent/var/log /mnt/var/log
# initialisation
mkdir -pv /mnt/nix/secret/initrd
chmod 0700 /mnt/nix/secret
chmod 0777 /mnt/nix/persistent/home/a4blue
# Generate SOPS Keys
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/initrd/sops_key
nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/nix/secret/initrd/sops_key.pub | ssh-to-age'

nixos-generate-config --root /mnt
git clone https://github.com/a4blue/own-nix-os-config.git /mnt/home/a4blue/own-nix-os-config
nixos-install --root /mnt --flake /mnt/home/nixos/own-nix-os-config#desktop
