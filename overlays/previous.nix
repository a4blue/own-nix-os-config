{
  nixpkgs,
  inputs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
      #git = inputs.nixpkgs-prev.legacyPackages.${prev.system}.git;

      #mesa = inputs.nixpkgs-unstable-small.legacyPackages.${prev.system}.mesa;
      linuxPackages_6_15 = prev.linuxPackagesFor (prev.linuxKernel.kernels.linux_6_15.override {
        argsOverride = rec {
          src = prev.fetchurl {
            url = "mirror://kernel/linux/kernel/v${lib.versions.major version}.x/linux-${version}.tar.xz";
            sha256 = "NFjNamxQjhYdvFQG5yuZ1dvfkp+vcEpn25ukbQdRSFg=";
          };
          version = "6.15.2";
          modDirVersion = "6.15.2";
        };
      });
    })
  ];
}
