{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    borgbackup
  ];

  systemd.packages = [pkgs.bcachefs-tools];

  sops.secrets.borgbackup_passphrase = {};

  services.borgbackup = {
    jobs = {
      persistent = {
        paths = ["/borgbackup"];
        exclude = ["'**/.cache'"];
        repo = "u401095@u401095.your-storagebox.de:/home/backups/homelab";
        encryption = {
          mode = "repokey";
          passCommand = "cat ${config.sops.secrets.borgbackup_passphrase.path}";
        };
        environment = {BORG_RSH = "ssh -p23 -i /nix/secret/hetzner_storage_box/ssh_hetzner_storage_box_ed25519_key";};
        compression = "zstd,10";
        startAt = "daily";
        preHook = "bcachefs subvolume snapshot /persistent/ /borgbackup";
        postHook = "bcachefs subvolume delete /borgbackup/";
        # TODO
        # Prune should be investigated
        #prune.keep = {};
      };
    };
  };

  #environment.persistence."/persistent" = {
  #  files = [
  #    "/root/.ssh/id_ed25519"
  #    "/root/.ssh/id_ed25519.pub"
  #  ];
  #};
}
