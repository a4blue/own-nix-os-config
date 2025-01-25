{
  nixpkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      pynitrokey = inputs.nixpkgs-prev.legacyPackages.${prev.system}.pynitrokey;
    })
  ];
}
