{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.virtualisation.podman.enable {
  virtualisation.podman = {
    dockerCompat = true;
    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };
}
