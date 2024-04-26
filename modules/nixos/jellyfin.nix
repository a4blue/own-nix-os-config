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
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };
  services.jellyfin = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
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
