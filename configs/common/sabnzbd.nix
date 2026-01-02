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

  config.environment = mkIf cfg.enable {systemPackages = with pkgs; [sabnzbd];};
  config.users.groups.smbUser = {
    members = ["sabnzbd"];
  };
}
