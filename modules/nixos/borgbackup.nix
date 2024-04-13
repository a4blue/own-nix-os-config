{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    borgbackup
  ];
  services.borgbackup = {
    #repos."hetzner_storage_box";
  };

  #environment.persistence."/persistent" = {
  #  files = [
  #    "/root/.ssh/id_ed25519"
  #    "/root/.ssh/id_ed25519.pub"
  #  ];
  #};
}
