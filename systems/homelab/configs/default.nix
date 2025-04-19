{
  pkgs,
  config,
  inputs,
  ...
}:
with config; {
  imports = [
    ./kernel-patch.nix
  ];
}
