{
  description = "Main Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    impermanence = {
      url = "github:nix-community/impermanence";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sops (secrets management)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-inspect = {
      url = "github:bluskript/nix-inspect";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko bcachefs support is not that great yet, disable for now
    #disko = {
    #  url = "github:nix-community/disko";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #flake-utils.url = "github:numtide/flake-utils/main";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
    # Enables `nix fmt` at root of repo to format all nix files
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    # or nix build ./#nixosConfigurations.homelab.config.system.build.toplevel
    nixosConfigurations = {
      homelab = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          ./systems/homelab/configuration.nix
          #inputs.disko.nixosModules.disko
        ];
      };
      # nix build .#nixosConfigurations.iso.config.system.build.isoImage
      iso = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
          ./systems/iso/configuration.nix
        ];
      };
    };
  };
}
