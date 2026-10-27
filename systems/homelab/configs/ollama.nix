{
  config,
  pkgs,
  ...
}: let
  serviceDomain = "ollama.home.a4blue.me";
in {
  sops.secrets = {
    "ollama/api_key" = {
      owner = "nginx";
      group = "nginx";
    };
  };
  services = {
    ####
    # Main Config
    ####
    ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      loadModels = ["qwen3.8:27b" "kaelri/qwen3.5-mt:2b"];
      syncModels = true;
      port = 11434;
      #openFirewall = true;
      environmentVariables = {
        OLLAMA_NO_CLOUD = "1";
        OLLAMA_IGPU_ENABLE = "1";
      };
    };
    ####
    # Nginx
    ####
    nginx.lua.enable = true;
    nginx.prependConfig = ''
      env OLLAMA_API_KEY;
    '';
    nginx.virtualHosts."${serviceDomain}" = {
      forceSSL = true;
      useACMEHost = "home.a4blue.me";
      # TODO inject API Key through Sops
      extraConfig = ''
        client_max_body_size 512M;
        add_header X-Content-Type-Options "nosniff";

        set_by_lua $ollama_api_key 'return io.open("${config.sops.secrets."ollama/api_key".path}", "r")';

        map $http_x_api_key $valid_key {
          default 0;
          $ollama_api_key 1;
        }
      '';
      locations."/" = {
        recommendedProxySettings = true;
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.ollama.port}";
        extraConfig = ''
          if ($valid_key = 0) {
            return 401; # Unauthorized
          }
        '';
      };
    };
  };
}
