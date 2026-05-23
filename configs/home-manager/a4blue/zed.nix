{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.zed-editor.enable {
  programs.zed-editor = {
    extensions = ["nix" "toml" "everforest-theme" "log" "json5" "php" "html" "dockerfile" "sql" "make" "lua" "xml" "csharp" "csv" "ini" "just"];
    userSettings = {
      "buffer_font_family" = "FiraCode Nerd Font Mono";
      "theme" = {
        "mode" = "system";
        "light" = "One Light";
        "dark" = "Everforest Dark Hard";
      };
    };
  };
  home.packages = [pkgs.nerd-fonts.fira-code];

  fonts.fontconfig.enable = true;
}
