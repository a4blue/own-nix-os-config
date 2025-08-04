{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    newSession = true;
    keyMode = "vi";
  };
}
