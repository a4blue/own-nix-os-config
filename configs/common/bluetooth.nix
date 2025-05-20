{
  lib,
  config,
  ...
}:
lib.mkIf config.hardware.bluetooth.enable {
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.hfphsp-backend" = "native";
      "bluez5.roles" = [
        "a2dp_sink"
        "a2dp_source"
        "bap_sink"
        "bap_source"
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
      ];
      "bluez5.codecs" = [
        "sbc"
        "sbc_xq"
        "aac"
        "ldac"
        "aptx"
        "aptx_hd"
        "aptx_ll"
        "aptx_ll_duplex"
        "faststream"
        "faststream_duplex"
        "lc3plus_h3"
        "opus_05"
        "opus_05_51"
        "opus_05_71"
        "opus_05_duplex"
        "opus_05_pro"
        "lc3"
      ];
    };
  };
  services.pipewire.wireplumber.extraConfig."11-bluetooth-policy" = {
    "wireplumber.settings" = {
      "bluetooth.autoswitch-to-headset-profile" = false;
    };
  };
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };
}
