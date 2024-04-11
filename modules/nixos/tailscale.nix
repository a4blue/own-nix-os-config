{config, ...}: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  environment.persistence."/persistence" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
