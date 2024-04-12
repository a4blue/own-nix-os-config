{config, ...}: {
  services.nextcloud = {
    enable = true;
    https = true;
    hostName = "homelab.armadillo-snake.ts.net/nextcloud";
    configureRedis = true;
    database.createLocally = true;
  };

  #environment.persistence."/persistent" = {
  #  directories = [
  #    "/var/lib/nextcloud"
  #  ];
  #};
}
