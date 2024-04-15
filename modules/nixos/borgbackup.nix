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
        compression = "zstd,16";
        startAt = "4h";
        preHook = "${pkgs.bcachefs-tools}/bin/bcachefs subvolume snapshot /persistent/ /tmp/borgbackup";
        postHook = "${pkgs.bcachefs-tools}/bin/bcachefs subvolume delete /tmp/borgbackup/";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
        inhibitsSleep = true;
      };
    };
  };

  environment.persistence."/persistent" = {
    files = [
      "/root/.ssh/known_hosts"
    ];
  };
}
