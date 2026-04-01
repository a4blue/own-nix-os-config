{config, ...}: let
  servicePort = 8097;
  serviceDomain = "koillection.home.a4blue.me";
in {
  virtualisation.oci-containers.containers = {
    koillection = {
      image = "docker.io/koillection/koillection:latest";
      autoStart = true;
      privileged = true;
      ports = ["127.0.0.1:${builtins.toString servicePort}:80"];
      volumes = ["/:/mnt/host:ro"];
      environment = {
      };
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_buffering off;
        allow 192.168.178.0/24;
        allow fd00:0:3ea6:2fff:0:0:0:0/64;
        deny all;
      '';
    };
  };
}
