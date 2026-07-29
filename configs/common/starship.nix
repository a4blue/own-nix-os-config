{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.programs.starship.enable {
  programs.starship.presets = ["nerd-font-symbols"];
  programs.starship.settings = {
    add_newline = true;
    direnv.disabled = false;
    status.disabled = false;
  };
}
