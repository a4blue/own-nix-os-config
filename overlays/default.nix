{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (self: super: {
      bcachefs-tools = super.bcachefs-tools.overrideAttrs (old: {
        version = "1.6.4";
        src = super.fetchFromGitHub {
          owner = "koverstreet";
          repo = "bcachefs-tools";
          rev = "v1.6.4";
          hash = "sha256-yyOjqiDiBXKcfIY58SuoZApjIdAeMbRSPxYDh76+XHE=";
        };
        cargoDeps = super.bcachefs-tools.rustPlatform.importCargoLock {
          lockFile = ./Cargo.lock;
          outputHashes = {
            "bindgen-0.64.0" = "sha256-GNG8as33HLRYJGYe0nw6qBzq86aHiGonyynEM7gaEE4=";
          };
        };
      });
    })
  ];
}
