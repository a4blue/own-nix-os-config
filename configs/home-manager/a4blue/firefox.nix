{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf (config.programs.firefox.enable) {
  programs.firefox.policies = {
    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };
    DisableAccounts = true;
    DisableFirefoxAccounts = true;
    DisablePocket = true;
    DontCheckDefaultBrowser = true;
    Preferences = {
      "gfx.webrender.all" = {Value = true;};
      "media.ffmpeg.vaapi.enabled" = {Value = true;};
    };
  };
  home.packages = with pkgs; [
    ffmpeg
  ];
}
