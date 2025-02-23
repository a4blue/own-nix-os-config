{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.fonts.fontconfig.enable) {
  fonts.fontconfig = {
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
      monospace = ["FiraCode Nerd Font Mono"];
      sansSerif = ["NotoSans Nerd Font"];
      serif = ["NotoSerif Nerd Font"];
    };
  };
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.noto
    noto-fonts-color-emoji
  ];
}
