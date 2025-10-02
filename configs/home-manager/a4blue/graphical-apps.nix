{
  lib,
  config,
  pkgs,
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
        "video/x-matroska" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };
  config.home =
    mkIf cfg.enable
    ((
        if config.modules.impermanenceExtra.enabled
        then {
          persistence."${config.modules.impermanenceExtra.defaultPath}" = {
            directories = [
              ".config/Proton Pass"
              ".config/Signal"
              ".local/share/chat.fluffy.fluffychat"
            ];
          };
        }
        else {}
      )
      // {
        packages = with pkgs; [
          signal-desktop
          fluffychat
          proton-pass
          joplin-desktop
          libreoffice-qt6-fresh
          vlc
          mpv
          podman-desktop
        ];
      });
}
