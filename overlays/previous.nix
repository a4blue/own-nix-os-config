{
  nixpkgs,
  inputs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
      pynitrokey = inputs.nixpkgs-stable.legacyPackages.${prev.system}.pynitrokey;
      forgejo-lts = inputs.nixpkgs-forgejo-fix.legacyPackages.${prev.system}.forgejo-lts;
    })
  ];
}
