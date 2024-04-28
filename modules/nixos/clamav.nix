{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    clamav
  ];
  services.clamav.updater = {
    enable = true;
  };
  services.clamav.daemon = {
    enable = true;
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/var/lib/clamav";
        mode = "0740";
        user = "clamav";
        group = "clamav";
      }
    ];
  };
}
