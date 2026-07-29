{
  config,
  pkgs,
  ...
}: {
  ####
  # Secrets
  ####
  sops.secrets.borgbackupPassphrase = {};
  ####
  # Main Config
  ####
  services.borgbackup = {
    jobs = {
      persistent = {
        paths = ["/tmp/borgbackup-home-a4blue" "/tmp/borgbackup-var-lib"];
        exclude = ["'**/.cache'"];
        repo = "u401095@u401095.your-storagebox.de:/home/backups/homelab";
        encryption = {
          mode = "repokey";
          passCommand = "cat ${config.sops.secrets.borgbackupPassphrase.path}";
        };
        environment = {BORG_RSH = "ssh -p23 -i /nix/secret/hetzner_storage_box/ssh_hetzner_storage_box_ed25519_key";};
        compression = "zstd,16";
        startAt = "daily";
        preHook = ''
          ${pkgs.bcachefs-tools}/bin/bcachefs subvolume snapshot /nix/persistent/var/lib/ /tmp/borgbackup-var-lib
          ${pkgs.bcachefs-tools}/bin/bcachefs subvolume snapshot /nix/persistent/home/a4blue/ /tmp/borgbackup-home-a4blue
        '';
        postHook = ''
          ${pkgs.bcachefs-tools}/bin/bcachefs subvolume delete /tmp/borgbackup-var-lib
          ${pkgs.bcachefs-tools}/bin/bcachefs subvolume delete /tmp/borgbackup-home-a4blue
        '';
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
  ####
  # Global Package
  ####
  environment.systemPackages = with pkgs; [
    borgbackup
  ];
  ####
  # Impermanence
  ####
  environment.persistence."${config.modules.impermanenceExtra.defaultPath}" = {
    files = [
      "/root/.ssh/known_hosts"
    ];
  };
}
