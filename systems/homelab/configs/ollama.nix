{
  config,
  pkgs,
  ...
}: {
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
      environmentVariables = {
        OLLAMA_NO_CLOUD = "1";
        OLLAMA_IGPU_ENABLE = "1";
      };
    };
  };
}
