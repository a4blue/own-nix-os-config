{
  config,
  inputs,
  outputs,
  pkgs-stable,
  ...
}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs outputs pkgs-stable;};
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
