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
      ".ssh"
      ".config/Proton Pass"
      ".config/Signal"
      ".local/share/baloo"
      ".local/share/chat.fluffy.fluffychat"
      ".local/share/simplex"
      ".pki"
      ".local/state/wireplumber"
      ".gnupg"
      #".var"
      # Will need cleanup
      ".cache"
    ];
    files = [
      # KDE Display Settings
      ".config/kwinoutputconfig.json"
    ];
  };
  # https://b.tuxes.uk/three-years-of-ephemeral-nixos.html
  # https://github.com/nix-community/plasma-manager
}
