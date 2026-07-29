{pkgs, ...}: let
  inherit (pkgs) rnnoise-plugin;
in {
  xdg.configFile."pipewire/pipewire.conf.d/61-rnnoise.conf" = {
    text = builtins.toJSON {
      "context.properties" = {
        "link.max-buffers" = 16;
        "core.daemon" = true;
        "core.name" = "pipewire-0";
        "module.x11.bell" = false;
        "module.access" = true;
        "module.jackdbus-detect" = false;
      };

      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Noise Canceling source";
            "media.name" = "Noise Canceling source";

            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)" = 80.0;
                    "VAD Grace Period (ms)" = 200;
                    "Retroactive VAD Grace (ms)" = 0;
                  };
                }
              ];
            };

            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              "audio.rate" = 48000;
            };

            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };
  xdg.configFile."pipewire/pipewire.conf.d/60-echo-cancel.conf" = {
    text = builtins.toJSON {
      "context.modules" = [
        {
          name = "libpipewire-module-echo-cancel";
          args = {
            "node.description" = "Echo Cancellation Source";
            "media.name" = "Echo Cancellation Source";
            "monitor.mode" = true;
            "capture.props" = {
              "node.name" = "capture.source_ec";
              "node.passive" = true;
            };
            "source.props" = {
              "node.name" = "source_ec";
              #  "node.description" = "Echo-cancelled source";
            };
            "aec.args" = {
              # Settings for the WebRTC echo cancellation engine
              "webrtc.gain_control" = true;
              #webrtc.extended_filter = true
            };
          };
        }
      ];
    };
  };
}
