{
  lib,
  pkgs,
  config,
  ...
}:
lib.mkIf config.programs.firefox.enable {
  programs.firefox = {
    policies = {
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
    languagePacks = ["en-US" "de"];
    nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];
  };
  home.packages = with pkgs; [
    ffmpeg
  ];
}
