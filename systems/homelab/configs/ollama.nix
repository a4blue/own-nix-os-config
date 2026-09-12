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
      loadModels = ["qwen3.5:9b" "qwen3.5:27b" "qwen3.8:27b"];
      syncModels = true;
    };
  };
}
