{
  description = "Main Flake";

  inputs = {
    # Nixpkgs
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-prev-unstable-small.url = "github:nixos/nixpkgs?rev=642fae6c6a7fbd9b9a61e2d3fc849c99bb4d485a";
    pyrate-fix.url = "github:yzhou216/pyrate-limiter-tests?rev=af5c66eab8ee227cd7fa0aa6b5c28d7db50b4372";

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nc4nix = {
      url = "github:helsinki-systems/nc4nix";
      flake = false;
    };

    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
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
            nh
            nix-du
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
            inputs.declarative-jellyfin.nixosModules.default
          ];
        };
        # nix build ./#nixosConfigurations.homelab-new.config.system.build.toplevel
        homelab-new = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs system;};
          modules = [
            {nixpkgs.hostPlatform = "x86_64-linux";}
            ./systems/homelab-new/configuration.nix
            ./overlays/previous.nix
            inputs.declarative-jellyfin.nixosModules.default
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
