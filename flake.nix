{
  description = "Main Flake";

  inputs = {
    # Nixpkgs
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    #nixpkgs.url = "github:nixos/nixpkgs?rev=9f4e767a3c29b591c32b2785f6a8997b2e60b949";

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    #bcachefs-tools = {
    #  url = "github:koverstreet/bcachefs-tools/master";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

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
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/master";
    };
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
    in {
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
            just
            nix-tree
            nix-output-monitor
            statix
            inputs.own-nixvim.packages.${system}.default
          ];
          shellHook = ''
            export PS1="\n[\u@nix-shell:\w\]$:\n"
          '';
        };
      };
    })
    // {
      nixosConfigurations = {
        # nix build ./#nixosConfigurations.homelab.config.system.build.toplevel
        homelab = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs system;};
          modules = [
            {nixpkgs.hostPlatform = "x86_64-linux";}
            ./systems/homelab/configuration.nix
            ./overlays/previous.nix
          ];
        };
        # nix build ./#nixosConfigurations.desktop.config.system.build.toplevel
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs system;};
          modules = [
            ./systems/desktop/configuration.nix
            ./overlays/previous.nix
          ];
        };
        # nix build ./#nixosConfigurations.laptop-nix.config.system.build.toplevel
        laptop-nix = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs system;};
          modules = [
            ./systems/laptop-nix/configuration.nix
            ./overlays/previous.nix
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
