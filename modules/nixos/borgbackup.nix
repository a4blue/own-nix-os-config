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
        paths = ["/tmp/borgbackup"];
        exclude = ["'**/.cache'"];
        repo = "u401095@u401095.your-storagebox.de:/home/backups/homelab";
        encryption = {
          mode = "repokey";
          passCommand = "cat ${config.sops.secrets.borgbackup_passphrase.path}";
        };
        environment = {BORG_RSH = "ssh -p23 -i /nix/secret/hetzner_storage_box/ssh_hetzner_storage_box_ed25519_key";};
        compression = "zstd,10";
        startAt = "daily";
        preHook = "${pkgs.bcachefs-tools}/bin/bcachefs subvolume snapshot /persistent/ /tmp/borgbackup";
        postHook = "${pkgs.bcachefs-tools}/bin/bcachefs subvolume delete /tmp/borgbackup/";
        # TODO
        # Prune should be investigated
        #prune.keep = {};
      };
    };
  };

  environment.persistence."/persistent" = {
    files = [
      "/root/.ssh/known_hosts"
    ];
  };
}
