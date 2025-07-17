{
  config,
  lib,
  ...
}:
lib.mkIf config.modules.impermanenceExtra.enabled {
  home.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    allowOther = true;
    directories = [
      "Development"
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Persistence"
      ".pki"
      # Sound settings
      ".local/state/wireplumber"
      # KDE Stuff
      ".local/share/baloo"
      ".local/share/klipper"
      # Will need cleanup
      ".cache"
      ".local/share/Haveno-reto"
      # Flatpack shared Data
      ".local/share/FlatPackData"
      ".local/share/xmr-btc-swap"
    ];
    files = [
      # KDE Display Settings
      ".config/kwinoutputconfig.json"
    ];
  };
  # https://b.tuxes.uk/three-years-of-ephemeral-nixos.html
  # https://github.com/nix-community/plasma-manager
}
