{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.impermanenceExtra;
in {
  options.modules.impermanenceExtra = {
    enabled = lib.mkOption {
      type = lib.types.bool;
      description = "Flag if impermanence is Enabled.";
    };
    defaultPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Default Path to use for Impermanence.";
    };
  };

  config.home = mkIf cfg.enabled {
    persistence = assert cfg.enabled -> cfg.defaultPath != null; {
    };
  };
}
