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
        # Echo cancellation
        {
          name = "libpipewire-module-echo-cancel";
          args = {
            "node.description" = "Echo Cancellation Source";
            "media.name" = "Echo Cancellation Source";
            # Monitor mode: Instead of creating a virtual sink into which all
            # applications must play, in PipeWire the echo cancellation module can read
            # the audio that should be cancelled directly from the current fallback
            # audio output
            "monitor.mode" = true;
            "capture.props" = {
              # The audio source / microphone the echo should be cancelled from
              # Can be found with: pw-cli list-objects Node | grep node.name
              # Optional; if not specified the module uses/follows the fallback audio source
              #node.target = "alsa_input.usb-UGREEN_Camera_UGREEN_Camera_SN0001-02.analog-stereo"
              # Passive node: Do not keep the microphone alive when this capture is idle
              "node.passive" = true;
            };
            "source.props" = {
              #  # The virtual audio source that provides the echo-cancelled microphone audio
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
  xdg.configFile."pipewire/pipewire.conf.d/62-echo-noise-cancel.conf" = {
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
            "node.description" = "Echo+Noise Canceling source";
            "media.name" = "Echo+Noise Canceling source";

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
              "node.name" = "capture.echo_rnnoise_source";
              "node.passive" = true;
              "audio.rate" = 48000;
              "node.target" = "source_ec";
            };

            "playback.props" = {
              "node.name" = "echo_rnnoise_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };
}
