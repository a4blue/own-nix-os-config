default:
  @just --list --justfile {{justfile()}}

update-diff: _build-systems _update-and-build-systems-1 _diff-systems

@_stash:
  git stash
@_stash-pop:
  -git stash pop
@_build-systems: _stash && _stash-pop
  mkdir -p gen
  #nix build .#nixosConfigurations.iso.config.system.build.isoImage -o gen/iso
  #nix build .#nixosConfigurations.gui-iso.config.system.build.isoImage -o gen/gui-iso
  #nix build .#nixosConfigurations.desktop-nix.config.system.build.toplevel -o gen/dektop
  nix build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab
@_update-and-build-systems-1:
  mkdir -p gen
  nix flake update --output-lock-file gen/flake.lock
  #nix build .#nixosConfigurations.iso.config.system.build.isoImage -o gen/iso1 --reference-lock-file gen/flake.lock
  #nix build .#nixosConfigurations.gui-iso.config.system.build.isoImage -o gen/gui-iso1 --reference-lock-file gen/flake.lock
  #nix build .#nixosConfigurations.desktop-nix.config.system.build.toplevel -o gen/dektop1 --reference-lock-file gen/flake.lock
  nix build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop1 --reference-lock-file gen/flake.lock
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab1 --reference-lock-file gen/flake.lock
@_diff-systems:
  #nvd diff gen/iso gen/iso1
  #nvd diff gen/gui-iso gen/gui-iso1
  #nvd diff gen/dektop gen/dektop1
  nvd diff gen/laptop gen/laptop1
  nvd diff gen/homelab gen/homelab1
