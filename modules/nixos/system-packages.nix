{
  pkgs,
  inputs,
  system,
  ...
}: {
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
    parted
    util-linux
    nvd
    #inputs.nix-inspect.packages.${system}.default
    strace
    perl
    rsync
    just
    zellij
    joshuto
    fzf
    zoxide
    wl-clipboard
    wl-clipboard-x11
    nix-tree
  ];
}
