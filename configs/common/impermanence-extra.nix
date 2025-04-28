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
      default = false;
      description = "Flag if impermanence is Enabled.";
    };
    defaultPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Default Path to use for Impermanence.";
    };
  };

  config.environment =
    if cfg.enabled
    then {
      persistence = assert cfg.enabled -> cfg.defaultPath != null; {
      };
    }
    else {};
}
