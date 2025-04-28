{
  pkgs,
  config,
  inputs,
  ...
}:
with config; {
  imports = [
    ./impermanence-extra.nix
  ];
}
