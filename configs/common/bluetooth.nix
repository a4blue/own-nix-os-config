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
      "bluez5.roles" = [
        "hsp_hs"
        "hsp_ag"
        "hfp_hf"
        "hfp_ag"
        "a2dp_sink"
        "a2dp_source"
        "bap_sink"
        "bap_source"
      ];
      "bluez5.codecs" = [
        "sbc"
        "sbc_xq"
        "aac"
        "aptx"
        "aptx_hd"
        "aptx_ll"
        "ldac"
        "aptx_ll_duplex"
      ];
    };
  };
}
