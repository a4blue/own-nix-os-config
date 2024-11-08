default:
  @just --list --justfile {{justfile()}}

update-diff:
  mkdir -p gen
  #nix build .#nixosConfigurations.iso.config.system.build.isoImage -o gen/iso
  #nix build .#nixosConfigurations.gui-iso.config.system.build.isoImage -o gen/gui-iso
  #nix build .#nixosConfigurations.desktop-nix.config.system.build.toplevel -o gen/dektop
  nix build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab
  nix flake update --output-lock-file gen/flake.lock
  #nix build .#nixosConfigurations.iso.config.system.build.isoImage -o gen/iso1 --reference-lock-file gen/flake.lock
  #nix build .#nixosConfigurations.gui-iso.config.system.build.isoImage -o gen/gui-iso1 --reference-lock-file gen/flake.lock
  #nix build .#nixosConfigurations.desktop-nix.config.system.build.toplevel -o gen/dektop1 --reference-lock-file gen/flake.lock
  nix build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop1 --reference-lock-file gen/flake.lock
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab1 --reference-lock-file gen/flake.lock
  #nvd diff gen/iso gen/iso1
  #nvd diff gen/gui-iso gen/gui-iso1
  #nvd diff gen/dektop gen/dektop1
  nvd diff gen/laptop gen/laptop1
  nvd diff gen/homelab gen/homelab1