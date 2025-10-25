{
  pkgs,
  config,
  inputs,
  ...
}:
with config; {
  imports = [
    ./large-media-mount.nix
    ./lanzaboote.nix
  ];
}
