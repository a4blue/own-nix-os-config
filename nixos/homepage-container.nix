{ config, pkgs, ... }:

{
  let THIS_DIR = builtins.toString ./configs/homepage; in
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    homepage-container = {
      image = "ghcr.io/gethomepage/homepage:latest";
      autoStart = true;
      ports = [ "3000:3000" ];
      volumes = [ "${THIS_DIR}:/app/config" "/var/run/docker.sock:/var/run/docker.sock" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ 3000 ];
}