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
          rev = "v${self.version}";
          hash = "010182e79051fccbedc35aaa55dc67266ae3b3d0";
        };
      });
    })
  ];
}
