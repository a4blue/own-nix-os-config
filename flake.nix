{
  description = "Main Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    impermanence = {
      url = "github:nix-community/impermanence";
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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    own-nixvim = {
      url = "github:a4blue/own-nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils/main";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";

    # Function to create Neovim packages with unique names
    mkNeovimPackages = pkgs: neovimPkgs: let
      mkNeovimAlias = name: pkg:
        pkgs.runCommand "neovim-${name}" {} ''
          mkdir -p $out/bin
          ln -s ${pkg}/bin/nvim $out/bin/nvim-${name}
        '';
    in
      builtins.mapAttrs mkNeovimAlias neovimPkgs;
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      #build-systems =
      #  pkgs.runCommandLocal "build-systems" {
      #  NIX_CONFIG = "experimental-features = nix-command flakes";
      #    src = ./.;
      #    nativeBuildInputs = with pkgs; [nix];
      #  } ''
      #    nix build ./#nixosConfigurations.homelab.config.system.build.toplevel
      #    nix build ./#nixosConfigurations.desktop-nix.config.system.build.toplevel
      #    nix build ./#nixosConfigurations.laptop-nix.config.system.build.toplevel
      #    mkdir "$out"
      #  '';
    in {
      #checks = {inherit build-systems;};
      formatter = pkgs.alejandra;
      devShells = {
        default = pkgs.mkShell {
          NIX_CONFIG = "experimental-features = nix-command flakes";
          packages = with pkgs; [
            gnupg
            sops
            nix
            git
            nvd
            age
            inputs.own-nixvim.packages.${system}.default
          ];
        };
      };
    })
    // {
      #nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
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
        # nix build ./#nixosConfigurations.laptop-nix.config.system.build.toplevel
        laptop-nix = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs system;};
          modules = [
            {nixpkgs.hostPlatform = "x86_64-linux";}
            ./systems/laptop-nix/configuration.nix
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
      };
    };
}
