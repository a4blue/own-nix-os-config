{config, ...}: {
  #fileSystems."/export/SDMedia" = {
  #  device = "/SDMedia";
  #  options = [ "bind" ];
  #};
  environment.persistence."/SDMedia" = {
    directories = [
      {
        directory = "/export/SDMedia";
        user = "nobody";
        group = "nogroup";
      }
    ];
  };
  services.nfs.server = {
    enable = true;
    exports = ''
      /export/SDMedia 192.168.178.0/24(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
    '';
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
  };
  networking.firewall.allowedTCPPorts = with config.services.nfs.server; [statdPort lockdPort mountdPort];
}
