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

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # Plugins not available in nixpkgs
    huez-nvim = {
      url = "github:vague2k/huez.nvim";
      flake = false;
    };
    blame-me-nvim = {
      url = "github:hougesen/blame-me.nvim";
      flake = false;
    };
    cmake-tools-nvim = {
      url = "github:Civitasv/cmake-tools.nvim";
      flake = false;
    };
    cmake-gtest-nvim = {
      url = "github:hfn92/cmake-gtest.nvim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
    # Enables `nix fmt` at root of repo to format all nix files
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # nix build ./#nixosConfigurations.homelab.config.system.build.toplevel
      homelab = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          ./systems/homelab/configuration.nix
        ];
      };
      # nix build ./#nixosConfigurations.desktop-nix.config.system.build.toplevel
      desktop-nix = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          ./systems/desktop-nix/configuration.nix
        ];
      };
      # nix build .#nixosConfigurations.iso.config.system.build.isoImage
      iso = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
          ./systems/iso/configuration.nix
        ];
      };
      # nix build .#nixosConfigurations.gui-iso.config.system.build.isoImage
      gui-iso = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix")
          ./systems/iso/configuration.nix
        ];
      };
      # nix build ./#nixosConfigurations.wsl.config.system.build.toplevel
      wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs system;};
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          nixos-wsl.nixosModules.default
          ./systems/wsl2/configuration.nix
        ];
      };
    };
  };
}
