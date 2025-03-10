{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.vscode.enable) {
  programs.vscode = {
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        kamadorueda.alejandra
      ];
      userSettings = {
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "FiraCode Nerd Font Mono";
      };
    };
  };
  home.packages = with pkgs; [
    nil
    alejandra
    nerd-fonts.fira-code
  ];
  fonts.fontconfig.enable = true;
}
