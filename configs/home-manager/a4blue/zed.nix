{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.zed-editor.enable {
  programs.zed-editor = {
    extensions = ["nix" "toml" "rust" "everforest-theme"];
    userSettings = {
      "theme" = "Everforest Dark Hard";
    };
  };
  home.packages = [pkgs.nerd-fonts.fira-code];

  fonts.fontconfig.enable = true;
}
