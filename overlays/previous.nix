{
  nixpkgs,
  inputs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
    (final: prev: {
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
      inherit (inputs.stash-update.legacyPackages.${prev.stdenv.hostPlatform.system}) stash;
    })
  ];
}
