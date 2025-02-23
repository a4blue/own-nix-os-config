{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.wezterm.enable) {
  programs.wezterm = {
    extraConfig = ''
      -- This will hold the configuration.
      local config = wezterm.config_builder()

      config.color_scheme = 'Everforest Dark (Gogh)'
      config.font = wezterm.font 'FiraCode Nerd Font Mono'
      config.disable_default_key_bindings = true
      config.keys = {
        -- CTRL-SHIFT-l activates the debug overlay
        { key = 'L', mods = 'CTRL', action = wezterm.action.ShowDebugOverlay },
        {
          key = 'P',
          mods = 'CTRL',
          action = wezterm.action.ActivateCommandPalette,
        },
      }
      -- FIX START
      -- Currently there are issues, this fixes it
      --config.front_end = "WebGpu"
      --config.enable_wayland = false
      -- FIX END

      -- and finally, return the configuration to wezterm
      return config
    '';
  };
  home.packages = [pkgs.nerd-fonts.fira-code];

  fonts.fontconfig.enable = true;
}
