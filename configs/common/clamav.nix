{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.services.clamav.daemon.enable {
  services.clamav.updater.enable = true;
  #services.clamav.fangfrisch.enable = true;
  services.clamav.daemon.settings = {
    "MaxThreads" = 1;
  };

  # TODO
  # This seems like a dirty solution
  environment =
    if config.modules.impermanenceExtra.enabled
    then {
      persistence."${config.modules.impermanenceExtra.defaultPath}" = {
        directories = [
          {
            directory = "/var/lib/clamav";
            mode = "0740";
            user = "clamav";
            group = "clamav";
          }
        ];
      };
      systemPackages = with pkgs; [
        clamav
      ];
    }
    else {
      systemPackages = with pkgs; [
        clamav
      ];
    };
}
