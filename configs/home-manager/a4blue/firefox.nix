{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
lib.mkIf config.programs.firefox.enable {
  programs.firefox = {
    package = inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
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
      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableProfileImport = true;
      DisableSetDesktopBackground = true;
      HttpsOnlyMode = "enabled";
      Preferences = {
        "gfx.webrender.all" = {Value = true;};
        "media.ffmpeg.vaapi.enabled" = {Value = true;};
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
    languagePacks = ["en-US" "de"];
    nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];
  };
  home =
    (
      if config.modules.impermanenceExtra.enabled
      then {
        persistence."${config.modules.impermanenceExtra.defaultPath}" = {
          directories = [
            ".mozilla"
          ];
        };
      }
      else {}
    )
    // {
      packages = with pkgs; [
        ffmpeg
      ];
    };
}
