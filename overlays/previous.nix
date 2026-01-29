{
  nixpkgs,
  inputs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    #inputs.attic.overlays.default
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
      #blocky = inputs.blocky-fix.legacyPackages.${prev.system}.blocky;
      #libreoffice-qt6-fresh = inputs.nixpkgs-prev-unstable-small.legacyPackages.${prev.system}.libreoffice-qt6-fresh;
      #python313 = prev.python313.override {
      #  packageOverrides = pyfinal: pyprev: {
      #    pyrate-limiter = pyprev.pyrate-limiter.overridePythonAttrs (old: {
      #      disabledTests = [
      #        # failing
      #        "test_limiter_01"
      #        "test_limiter_async_factory_get"
      #        "test_bucket_flush"
      #        "test_bucket_leak"
      #      ];
      #    });
      #  };
      #};
      mnamer2 = prev.callPackage ../packages/mnamer-fork/mnamer2.nix {};
      stash = inputs.stash-update.legacyPackages.${prev.system}.stash;
      proton-ge-10-29 = prev.callPackage ../packages/proton-ge/10-29.nix {};
    })
  ];
}
