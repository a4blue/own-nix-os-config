{config, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
