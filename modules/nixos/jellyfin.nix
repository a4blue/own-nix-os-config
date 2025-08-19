{
  config,
  pkgs,
  ...
}: let
  servicePort = 8096;
  serviceDomain = "jellyfin.homelab.internal";
in {
  imports = [
    ./nginx.nix
  ];

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva-vdpau-driver
      intel-compute-runtime
      vpl-gpu-rt
      intel-ocl
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts."${serviceDomain}" = {
    forceSSL = true;
    sslCertificateKey = "/var/lib/self-signed-nginx-cert/homelab-local-root.key";
    sslCertificate = "/var/lib/self-signed-nginx-cert/wildcard-homelab-local.pem";
    extraConfig = ''
      ssl_stapling off;
    '';
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
        proxy_buffering off;
      '';
    };
    locations."/socket" = {
      recommendedProxySettings = true;
      proxyPass = "http://localhost:${builtins.toString servicePort}";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Protocol $scheme;
        deny 192.168.178.1;
        allow 192.168.178.0/24;
        deny all;
      '';
    };
  };

  users.users.jellyfin.extraGroups = ["render" "smbUser" "video"];

  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    directories = [
      {
        directory = "/var/lib/jellyfin";
        mode = "0740";
        user = "jellyfin";
        group = "jellyfin";
      }
    ];
  };
}
