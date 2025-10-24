default:
  @just --list --justfile {{justfile()}}

update-diff: _build-systems _update-and-build-systems-1 _diff-systems
@_stash:
  git stash
@_stash-pop:
  -git stash pop
@_build-systems: _stash && _stash-pop
  mkdir -p gen
  nom build .#nixosConfigurations.desktop.config.system.build.toplevel -o gen/dektop
  nom build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop
  nom build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab
  nom build .#nixosConfigurations.homelab-new.config.system.build.toplevel -o gen/homelab-new
@_update-and-build-systems-1:
  mkdir -p gen
  nix flake update --output-lock-file gen/flake.lock
  nom build .#nixosConfigurations.desktop.config.system.build.toplevel -o gen/dektop1 --reference-lock-file gen/flake.lock
  nom build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop1 --reference-lock-file gen/flake.lock
  nom build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab1 --reference-lock-file gen/flake.lock
  nom build .#nixosConfigurations.homelab-new.config.system.build.toplevel -o gen/homelab-new1 --reference-lock-file gen/flake.lock
@_diff-systems:
  nvd diff gen/dektop gen/dektop1
  nvd diff gen/laptop gen/laptop1
  nvd diff gen/homelab gen/homelab1
  nvd diff gen/homelab-new gen/homelab-new1
