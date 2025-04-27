{
  home.persistence."/nix/persistent/home/a4blue" = {
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
      ".mozilla"
      ".local/share/Steam"
      ".config/Proton Pass"
      ".config/heroic"
      ".config/Signal"
      ".config/VSCodium"
      ".local/share/lutris"
      ".local/share/bottles"
      ".local/share/baloo"
      ".local/share/chat.fluffy.fluffychat"
      ".local/share/simplex"
      ".pki"
      ".local/state/wireplumber"
      #".gnupg"
      #".var"
      #".vscode-oss"
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
