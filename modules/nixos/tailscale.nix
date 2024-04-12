{config, ...}: {
  sops.secrets.tailscale-auth-key = {};
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale-auth-key.path;
  };

  environment.persistence."/persistent" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
