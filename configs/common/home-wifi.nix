{
  lib,
  config,
  ...
}: {
  # Non-GUI with wpa_supplicant
  config = {
    sops.secrets.homeWifiPsk = {};
    networking.wireless = lib.mkIf config.networking.wireless.enable {
      secretsFile = config.sops.secrets.homeWifiPsk.path;
    };

    networking.networkmanager = lib.mkIf config.networking.networkmanager.enable {
      ensureProfiles.environmentFiles = [config.sops.secrets.homeWifiPsk.path];
      ensureProfiles.profiles = {
        "NoNameWLAN 5GHz" = {
          connection = {
            id = "NoNameWLAN 5GHz";
            permissions = "";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "NoNameWLAN 5GHz";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$HOME_WIFI_PSK";
          };
        };
        "NoNameWLAN 2.4GHz" = {
          connection = {
            id = "NoNameWLAN 2.4GHz";
            permissions = "";
            type = "wifi";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "NoNameWLAN 2.4GHz";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$HOME_WIFI_PSK";
          };
        };
      };
    };
  };
}
