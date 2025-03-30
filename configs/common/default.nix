{
  pkgs,
  config,
  inputs,
  ...
}:
with config; {
  imports = [
    ./localisation.nix
    ./steam.nix
  ];
}
