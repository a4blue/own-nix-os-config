{
  lib,
  config,
  pkgs,
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
            ];
          };
        }
        else {}
      )
      // {
        packages = with pkgs; [
          wineWowPackages.stable
          winetricks
          bottles
          lutris
          heroic
          mangohud
          protonup-qt
          protontricks
        ];
      });
}
