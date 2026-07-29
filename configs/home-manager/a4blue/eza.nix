{
  lib,
  pkgs,
  config,
  ...
}: {
  home.file = {
    ".config/eza/theme.yml".source = ./eza/theme.yml;
  };
}
