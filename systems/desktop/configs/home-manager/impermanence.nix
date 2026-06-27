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
      "${config.xdg.dataHome}/tpm2-pkcs11"
      "${config.xdg.dataHome}/tpm2-tss"
      # Sound settings
      ".local/state/wireplumber"
      # KDE Stuff
      "${config.xdg.dataHome}/baloo"
      "${config.xdg.dataHome}/klipper"
      "${config.xdg.dataHome}/krdc"
      "${config.xdg.dataHome}/kwalletd"
      "${config.xdg.dataHome}/dolphin"
      # Will need cleanup
      ".cache"
      "${config.xdg.dataHome}/Haveno-reto"
      # Flatpack shared Data
      "${config.xdg.dataHome}/FlatPackData"
      "${config.xdg.dataHome}/xmr-btc-swap"
      # Podman
      "${config.xdg.dataHome}/containers"
      # qBitTorrent (Considering auto Setup with Linux Distro Seed ?)
      "${config.xdg.dataHome}/qBittorrent"
      "${config.xdg.configHome}/qBittorrent"
      "${config.xdg.configHome}/zed"
      "${config.xdg.dataHome}/zed"
    ];
    files = [
      # KDE Stuff
      "${config.xdg.configHome}/kwinoutputconfig.json"
      "${config.xdg.configHome}/krdcrc"
      "${config.xdg.configHome}/kwalletrc"
      "${config.xdg.configHome}/dolphinrc"
    ];
  };
  # https://b.tuxes.uk/three-years-of-ephemeral-nixos.html
  # https://github.com/nix-community/plasma-manager
}
