{config, ...}: {
  services.duplicati = {
    enable = true;
    interface = "127.0.0.1";
    port = 8200;
    # sadly i cant easily define group, so
    user = "root";
  };
}
