{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.alacritty.enable) {
  programs.alacritty = {
    settings = {
      window = {
        position = "None";
        # Leads to an error right now
        #padding = {
        #  x = 1;
        #  y = 1;
        #};
        decorations = "Full";
        startup_mode = "Maximized";
      };
      scrolling.history = 100000;
      font = {
        normal.family = "FiraCode Nerd Font Mono";
      };
      colors = {
        primary = {
          foreground = "#d3c6aa";
          background = "#272e33";
        };
        normal = {
          black = "#414b50";
          red = "#e67e80";
          green = "#a7c080";
          yellow = "#dbbc7f";
          blue = "#7fbbb3";
          magenta = "#d699b6";
          cyan = "#83c092";
          white = "#d3c6aa";
        };
        bright = {
          black = "#475258";
          red = "#e67e80";
          green = "#a7c080";
          yellow = "#dbbc7f";
          blue = "#7fbbb3";
          magenta = "#d699b6";
          cyan = "#83c092";
          white = "#d3c6aa";
        };
      };
    };
  };
  home.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
  fonts.fontconfig.enable = true;
}
