{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.git.enable {
  programs.git = {
    settings = {
      user.name = "Alexander Ratajczak";
      user.email = "a4blue@hotmail.de";
    };
    signing.format = "openpgp";
  };
}
