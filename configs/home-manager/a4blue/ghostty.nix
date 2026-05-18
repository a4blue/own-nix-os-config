{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.ghostty.enable {
  programs.ghostty = {
    enableBashIntegration = true;
    installBatSyntax = true;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      theme = "Everforest Dark Med";
      bell-features = "system,attention,title";
    };
  };
}
