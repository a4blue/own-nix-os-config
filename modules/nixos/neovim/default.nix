{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Derivation containing all plugins
  pluginPath = import ./plugins.nix {inherit pkgs lib inputs;};

  # Derivation containing all runtime dependencies
  runtimePath = import ./runtime.nix {inherit pkgs;};

  # Link together all treesitter grammars into single derivation
  treesitterPath = pkgs.symlinkJoin {
    name = "lazyvim-nix-treesitter-parsers";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };

  # codelldb executable is not exported by default
  codelldb = pkgs.writeShellScriptBin "codelldb" ''
    nix shell --impure --expr 'with import (builtins.getFlake "nixpkgs") {}; writeShellScriptBin "codelldb" "''${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb $@"' --command codelldb "$@"
  '';

  # cmake-lint is used as cmakelint
  cmakelint = pkgs.writeShellScriptBin "cmakelint" ''
    nix shell nixpkgs#cmake-format --command cmake-lint "$@"
  '';

  clangd = pkgs.writeShellScriptBin "clangd" ''
    if [ -f /opt/vector-clang-tidy/bin/clangd ]; then
      /opt/vector-clang-tidy/bin/clangd "$@"
    else
      nix shell nixpkgs#clang-tools_16 --command clangd "$@"
    fi
  '';

  make-lazy = pkg: bin:
    pkgs.writeShellScriptBin "${bin}" ''
      nix shell nixpkgs#${pkg} --command ${bin} "$@"
    '';
in {
  environment.systemPackages = with pkgs; [
    fd
    lazygit
    ripgrep
    fish
    shfmt
    stylua
    xdg-utils
    luajitPackages.jsregexp
    markdownlint-cli
    cmakelint
    clangd
    nil
    tree-sitter
    nodejs_20
  ];
  programs.neovim = {
    enable = true;

    configure = {
      customRC = ''
        " Populate paths to neovim
        let g:config_path = "${./config}"
        let g:plugin_path = "${pluginPath}"
        let g:runtime_path = "${runtimePath}"
        let g:treesitter_path = "${treesitterPath}"
        " Begin initialization
        source ${./config/init.lua}
      '';
      packages.all.start = [pkgs.vimPlugins.lazy-nvim];
    };
  };
}
