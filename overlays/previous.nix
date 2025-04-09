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
    })
  ];
}
