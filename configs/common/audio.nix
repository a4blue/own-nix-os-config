{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktopAudio;
in {
  options.modules.desktopAudio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Flag if Desktop Audio is Enabled.";
    };
  };

  config = mkIf cfg.enable {
    users.users.a4blue.extraGroups = ["audio"];
    boot = {
      kernel.sysctl = {
        "vm.swappiness" = 10;
      };
      kernelParams = ["threadirqs"];
    };
    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "@audio";
        item = "nofile";
        type = "-";
        value = "99999";
      }
    ];
    services.udev.extraRules = ''
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
    '';

    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      extraConfig.pipewire."51-disable-suspension" = {
        "monitor.alsa.rules" = [
          {
            "matches" = [
              {
                "node.name" = "~alsa_input.*";
              }
              {
                "node.name" = "~alsa_output.*";
              }
            ];
            "actions" = {
              "update-props" = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
      extraConfig.pipewire."92-stutter-fix" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 512;
        };
      };
    };
  };
}
