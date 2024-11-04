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
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    jellyfin-ffmpeg = pkgs.jellyfin-ffmpeg.override {
      ffmpeg_7-full = pkgs.ffmpeg_7-full.override {
        withXevd = false;
        withXeve = false;
      };
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    #jellyfin-ffmpeg
    intel-media-sdk
    vpl-gpu-rt
    libvpl
    vdpauinfo
  ];

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

  users.users.jellyfin.extraGroups = ["render" "smbUser"];

  environment.persistence."/persistent" = {
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
