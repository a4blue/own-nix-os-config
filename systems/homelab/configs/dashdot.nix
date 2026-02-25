{config, ...}: let
  servicePort = 8098;
  serviceDomain = "dashdot.home.a4blue.me";
in {
  virtualisation.oci-containers.containers = {
    dashdot = {
      image = "docker.io/mauricenino/dashdot:latest";
      autoStart = true;
      privileged = true;
      ports = ["127.0.0.1:${builtins.toString servicePort}:3001"];
      volumes = ["/:/mnt/host:ro"];
      environment = {
        DASHDOT_WIDGET_LIST = "cpu,storage,ram,network,gpu";
        DASHDOT_ENABLE_CPU_TEMPS = "true";
      };
    };
  };
  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    useACMEHost = "home.a4blue.me";
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:${builtins.toString servicePort}/";
    };
  };
}
