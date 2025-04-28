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
              ".local/share/simplex"
            ];
          };
        }
        else {}
      )
      // {
        packages = with pkgs; [
          element-desktop
          simplex-chat-desktop
          signal-desktop-bin
          fluffychat
          proton-pass
          joplin-desktop
          libreoffice-qt6-fresh
          vlc
          mpv
          handbrake
          podman-desktop
        ];
      });
}
