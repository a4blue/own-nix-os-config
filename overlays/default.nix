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
          hash = lib.fakeSha256;
        };
      });
    })
  ];
}
