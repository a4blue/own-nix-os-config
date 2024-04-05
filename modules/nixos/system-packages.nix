{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    home-manager
    nano
    efibootmgr
    gptfdisk
    curl
    ranger
    tmux
    sops
  ];
}
