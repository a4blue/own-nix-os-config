{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.vscode.enable) {
  programs.vscode = {
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      kamadorueda.alejandra
    ];
  };
  home.packages = with pkgs; [
    nil
    alejandra
    nerd-fonts.fira-code
  ];
  fonts.fontconfig.enable = true;
}
