{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.navi.enable {
  programs.navi = {
    settings = {
      cheats.paths = [
        "${config.xdg.configHome}/navi-cheats/"
      ];
    };
  };

  home.file = {
    "${config.xdg.configHome}/navi-cheats/default.cheat".source = ./navi-cheats/default.cheat;
    "${config.xdg.configHome}/navi-cheats/fontconfig.cheat".source = lib.mkIf config.fonts.fontconfig.enable ./navi-cheats/fontconfig.cheat;
  };
}
