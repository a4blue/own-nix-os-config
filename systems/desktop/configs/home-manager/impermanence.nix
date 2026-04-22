{
  config,
  lib,
  ...
}:
lib.mkIf config.modules.impermanenceExtra.enabled {
  home.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      "Development"
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Persistence"
      ".pki"
      ".local/share/tpm2-pkcs11"
      ".local/share/tpm2-tss"
      # Sound settings
      ".local/state/wireplumber"
      # KDE Stuff
      ".local/share/baloo"
      ".local/share/klipper"
      ".local/share/krdc"
      ".local/share/kwalletd"
      ".local/share/dolphin"
      # Will need cleanup
      ".cache"
      ".local/share/Haveno-reto"
      # Flatpack shared Data
      ".local/share/FlatPackData"
      ".local/share/xmr-btc-swap"
      # Podman
      ".local/share/containers"
      # qBitTorrent (Considering auto Setup with Linux Distro Seed ?)
      ".local/share/qBittorrent"
      ".config/qBittorrent"
    ];
    files = [
      # KDE Stuff
      ".config/kwinoutputconfig.json"
      ".config/krdcrc"
      ".config/kwalletrc"
      ".config/dolphinrc"
    ];
  };
  # https://b.tuxes.uk/three-years-of-ephemeral-nixos.html
  # https://github.com/nix-community/plasma-manager
}
