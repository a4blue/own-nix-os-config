{
  nixpkgs,
  inputs,
  lib,
  ...
}: let
  pyrate-prev = import inputs.pyrate-fix {system = "x86_64-linux";};
in {
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
      libreoffice-qt6-fresh = inputs.nixpkgs-prev-unstable-small.legacyPackages.${prev.system}.libreoffice-qt6-fresh;
      #python313Packages.pyrate-limiter = pyrate-prev.python313Packages.pyrate-limiter;
    })
  ];
}
