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
      theme = "Everforest Dark Hard";
      bell-features = "system,attention,title";
      shell-integration-features = "sudo,ssh-env,title";
    };
  };
}
