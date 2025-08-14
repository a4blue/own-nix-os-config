{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.services.printing.enable {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
}
