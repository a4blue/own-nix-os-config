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
in {
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
