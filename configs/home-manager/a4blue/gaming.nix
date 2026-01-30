{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.modules.gaming;
in {
  options.modules.gaming = {
    enable = lib.mkEnableOption "Enable Gaming Apps";
  };

  config.home =
    mkIf cfg.enable
    ((
        if config.modules.impermanenceExtra.enabled
        then {
          persistence."${config.modules.impermanenceExtra.defaultPath}" = {
            directories = [
              ".config/heroic"
              ".local/share/Steam"
              ".local/share/lutris"
              ".local/share/bottles"
              ".local/share/umu"
              ".local/share/comet"
              ".config/steamtinkerlaunch"
              ".config/MangoHud/MangoHud.conf"
              ".paradoxlauncher"
              ".factorio"
              ".local/share/7DaysToDie"
            ];
          };
        }
        else {}
      )
      // {
        packages = with pkgs; [
          wineWowPackages.unstable
          winetricks
          bottles
          lutris
          umu-launcher
          (heroic.override {
            extraPkgs = pkgs: [
              pkgs.gamescope
              pkgs.gamemode
              pkgs.mangohud
            ];
          })
          mangohud
          protonup-qt
          protontricks
        ];
      });
}
