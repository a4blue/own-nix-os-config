{
  nixpkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      #pynitrokey = inputs.nixpkgs-prev.legacyPackages.${prev.system}.pynitrokey;
      #forgejo-lts = inputs.nixpkgs-prev.legacyPackages.${prev.system}.forgejo-lts;
      #mesa = inputs.nixpkgs-unstable-small.legacyPackages.${prev.system}.mesa;
      #linuxPackages_6_14 = inputs.nixpkgs-unstable-small.legacyPackages.${prev.system}.linuxPackages_6_14;
      nitrokey-udev-rules = prev.nitrokey-udev-rules.overrideAttrs (old: {
        version = "1.1.0";
        src = prev.fetchFromGitHub {
          owner = "Nitrokey";
          repo = "nitrokey-udev-rules";
          rev = "v1.1.0";
          hash = "sha256-LKpd6O9suAc2+FFgpuyTClEgL/JiZiokH3DV8P3C7Aw=";
        };
        nativeBuildInputs = [final.pkgs.ruff final.pkgs.pyright];
      });
    })
  ];
}
