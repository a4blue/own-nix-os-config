{
  lib,
  config,
  ...
}: {
  # Non-GUI with wpa_supplicant
  config.sops.secrets.home_wifi_psk = {};
  config.networking.wireless = lib.mkIf config.networking.wireless.enable {
    secretsFile = config.sops.secrets.home_wifi_psk.path;
    networks."NoNameWLAN" = {
      pskRaw = "ext:HOME_WIFI_PSK";
    };
  };

  config.networking.networkmanager = lib.mkIf config.networking.networkmanager.enable {
    ensureProfiles.environmentFiles = [config.sops.secrets.home_wifi_psk.path];
    ensureProfiles.profiles = {
      "NoNameWLAN" = {
        connection = {
          id = "NoNameWLAN";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "NoNameWLAN";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$HOME_WIFI_PSK";
        };
      };
    };
  };
}
