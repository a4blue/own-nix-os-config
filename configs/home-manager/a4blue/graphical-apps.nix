{
  lib,
  config,
  pkgs,
  pkgs-stable,
  ...
}:
with lib; let
  cfg = config.modules.graphicalApps;
in {
  options.modules.graphicalApps = {
    enable = lib.mkEnableOption "Enable Graphical Apps";
  };

  config.xdg = mkIf cfg.enable {
    mimeApps = {
      enable = true;
      defaultApplications = {
        #"video/x-matroska" = "vlc.desktop";
        #"video/mp4" = "vlc.desktop";
        "text/html" = "firefox-beta.desktop";
        "x-scheme-handler/http" = "firefox-beta.desktop";
        "x-scheme-handler/https" = "firefox-beta.desktop";
        "x-scheme-handler/about" = "firefox-beta.desktop";
        "x-scheme-handler/unknown" = "firefox-beta.desktop";
      };
    };
  };
  config.home = mkIf cfg.enable (
    (
      if config.modules.impermanenceExtra.enabled
      then {
        persistence."${config.modules.impermanenceExtra.defaultPath}" = {
          directories = [
            "${config.xdg.configHome}/Proton Pass"
            "${config.xdg.configHome}/Signal"
            "${config.xdg.dataHome}/chat.fluffy.fluffychat"
          ];
        };
      }
      else {}
    )
    // {
      packages = with pkgs-stable; [
        signal-desktop
        proton-pass
        libreoffice-qt6-fresh
        haruna
        podman-desktop
        kdePackages.kcalc
        kronometer
        kdePackages.kgpg
        kdePackages.kleopatra
        kdePackages.ktimer
        kdePackages.ktrip
        krita
        kdePackages.kolourpaint
        filezilla
        fluffychat
      ];
    }
  );
}
