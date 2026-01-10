default:
  @just --list --justfile {{justfile()}}

update-diff: _build-systems _update-and-build-systems-1 _diff-systems
diff: _build-systems _copy-current-lock _build-systems-1 _diff-systems
@_stash:
  git stash
@_stash-pop:
  -git stash pop
@_stash-apply:
  -git stash apply
@_build-systems: _stash && _stash-pop
  mkdir -p gen
  nix build .#nixosConfigurations.desktop.config.system.build.toplevel -o gen/dektop
  nix build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab
@_update-and-build-systems-1: _update_systems _build-systems-1
@_build-systems-1:
  nix build .#nixosConfigurations.desktop.config.system.build.toplevel -o gen/dektop1 --reference-lock-file gen/flake.lock
  nix build .#nixosConfigurations.laptop-nix.config.system.build.toplevel -o gen/laptop1 --reference-lock-file gen/flake.lock
  nix build .#nixosConfigurations.homelab.config.system.build.toplevel -o gen/homelab1 --reference-lock-file gen/flake.lock
@_diff-systems:
  nvd diff gen/dektop gen/dektop1
  nvd diff gen/laptop gen/laptop1
  nvd diff gen/homelab gen/homelab1
@_update_systems:
  mkdir -p gen
  nix flake update --output-lock-file gen/flake.lock
@_copy-current-lock:
  mkdir -p gen
  cp flake.lock gen/flake.lock

