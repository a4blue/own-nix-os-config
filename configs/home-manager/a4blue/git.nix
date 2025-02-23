{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.git.enable) {
  programs.git = {
    userName = "Alexander Ratajczak";
    userEmail = "a4blue@hotmail.de";
    signing.format = "openpgp";
  };
}
