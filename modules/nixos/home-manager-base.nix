{
  config,
  inputs,
  outputs,
  ...
}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
