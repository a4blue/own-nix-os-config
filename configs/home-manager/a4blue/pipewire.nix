{pkgs, ...}: let
  #inherit (pkgs) rnnoise-plugin calf lsp-plugins deepfilternet;
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
                  plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
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
  xdg.configFile."pipewire/pipewire.conf.d/62-deepfilternet.conf" = {
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
            "node.description" = "Deep Noise Canceling source";
            "media.name" = "Deep Noise Canceling source";

            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "deepfilternet";
                  plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                  label = "deep_filter_mono";
                  control = {
                    "Attenuation Limit (dB)" = 100;
                  };
                }
              ];
            };

            "capture.props" = {
              "node.name" = "capture.deepfilternet_source";
              "node.passive" = true;
              "audio.rate" = 48000;
            };

            "playback.props" = {
              "node.name" = "deepfilternet_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };
  # Additional configs here https://wiki.archlinux.org/title/PipeWire/Examples#Voice_processing
}
