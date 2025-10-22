{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.vscode.enable {
  programs.vscode = {
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        # Broken for now
        #jnoortheen.nix-ide
        #kamadorueda.alejandra
        #sainnhe.everforest
      ];
      userSettings = {
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "FiraCode Nerd Font Mono";
      };
    };
  };
  fonts.fontconfig.enable = true;
  home =
    (
      if config.modules.impermanenceExtra.enabled
      then {
        persistence."${config.modules.impermanenceExtra.defaultPath}" = {
          directories = [
            ".config/VSCodium"
            # Investigate if it is needed
            #".vscode-oss"
          ];
        };
      }
      else {}
    )
    // {
      packages = with pkgs; [
        nil
        alejandra
        nerd-fonts.fira-code
      ];
    };
}
