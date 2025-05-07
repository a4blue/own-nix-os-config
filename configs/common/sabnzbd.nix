{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.sabnzbd;
in {
  options.modules.sabnzbd = {
    enable = lib.mkEnableOption "Enable Sabnzbd";
  };

  #config.nixpkgs.config.allowUnfreePredicate = pkg:
  #  builtins.elem (lib.getName pkg) [
  #    "unrar"
  #  ];
  config.environment = mkIf cfg.enable {systemPackages = with pkgs; [sabnzbd];};
}
