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

  config.home = mkIf cfg.enable (
    (
      if config.modules.impermanenceExtra.enabled
      then {
        persistence."${config.modules.impermanenceExtra.defaultPath}" = {
          directories = [
            "${config.xdg.configHome}/heroic"
            "${config.xdg.dataHome}/Steam"
            "${config.xdg.dataHome}/lutris"
            "${config.xdg.dataHome}/bottles"
            "${config.xdg.dataHome}/umu"
            "${config.xdg.dataHome}/comet"
            "${config.xdg.configHome}/steamtinkerlaunch"
            "${config.xdg.configHome}/MangoHud/MangoHud.conf"
            ".paradoxlauncher"
            ".factorio"
            "${config.xdg.dataHome}/7DaysToDie"
            "${config.xdg.dataHome}/Paradox Interactive"
            "${config.xdg.dataHome}/Larian Studios"
          ];
        };
      }
      else {}
    )
    // {
      packages = with pkgs; [
        winetricks
        bottles
        lutris
        umu-launcher
        (heroic.override {
          extraPkgs = pkgs: [
            gamescope
            gamemode
            mangohud
            freetype
          ];
          extraLibraries = pkgs: [freetype];
        })
        mangohud
        protonup-qt
      ];
    }
  );
}
