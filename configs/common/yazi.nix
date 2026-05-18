{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.yazi.enable {
  programs.yazi = {
    plugins = {
      inherit (pkgs.yaziPlugins) git sudo chmod;
    };
  };
  environment.systemPackages = with pkgs; [
    git
  ];
}
