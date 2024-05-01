{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.own.vscode-remote-wsl;
in {
  options.own.vscode-remote-wsl = {
    enable = mkEnableOption (lib.mdDoc ''
      VSCode Remote WSL fix
      Remember to also enable following in System Configuration:
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        pkgs.stdenv.cc.cc
      ];
      environment.systemPackages = with pkgs; [
        wget
      ];
    '');
    nixos-version = mkOption {
      type = with types; (enum ["unstable" "23.11" "24.05"]);
      default = "unstable";
      example = "unstable";
      description = lib.mdDoc "NixOS Version to use for nix shell";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wget
    ];
    # Script is from https://github.com/sonowz/vscode-remote-wsl-nixos
    home.file.".vscode-server/server-env-setup".text = ''
      # This shell script is run before checking for vscode version updates.
      # If a newer version is downloaded, this script won't patch that version,
      # resulting in error. Therefore retry is required to patch it.

      echo "== '~/.vscode-server/server-env-setup' SCRIPT START =="

      # Make sure that basic commands are available
      PATH=$PATH:/run/current-system/sw/bin/

      # This shell script uses nixpkgs branch from OS version.
      # If you want to change this behavior, change environment variable below.
      #   e.g. NIXOS_VERSION=unstable
      NIXOS_VERSION=${cfg.nixos-version}
      echo "NIXOS_VERSION detected as \"$NIXOS_VERSION\""

      NIXPKGS_BRANCH=nixos-$NIXOS_VERSION
      PKGS_EXPRESSION=nixpkgs/$NIXPKGS_BRANCH#pkgs

      # Get directory where this shell script is located
      VSCODE_SERVER_DIR="$( cd "$( dirname "$\{BASH_SOURCE [0]}" )" >/dev/null 2>&1 && pwd )"
      echo "Got vscode directory : $VSCODE_SERVER_DIR"
      echo "If the directory is incorrect, you can hardcode it on the script."

      echo "Patching nodejs binaries..."
      nix shell $PKGS_EXPRESSION.patchelf $PKGS_EXPRESSION.stdenv.cc -c bash -c "
          for versiondir in $VSCODE_SERVER_DIR/bin/*/; do
              # Currently only "libstdc++.so.6" needs to be patched
              patchelf --set-interpreter \"\$(cat \$(nix eval --raw $PKGS_EXPRESSION.stdenv.cc)/nix-support/dynamic-linker)\" --set-rpath \"\$(nix eval --raw $PKGS_EXPRESSION.stdenv.cc.cc.lib)/lib/\" \"\$versiondir>        patchelf --set-interpreter \"\$(cat \$(nix eval --raw $PKGS_EXPRESSION.stdenv.cc)/nix-support/dynamic-linker)\" --set-rpath \"\$(nix eval --raw $PKGS_EXPRESSION.stdenv.cc.cc.lib)/lib/\" \"\$versiondir>    done
      "

      echo "== '~/.vscode-server/server-env-setup' SCRIPT END =="
    '';
  };
}
