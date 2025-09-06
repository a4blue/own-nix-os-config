{
  pkgs,
  config,
  inputs,
  ...
}:
with config; {
  imports = [
    ./localisation.nix
    ./steam.nix
    ./home-wifi.nix
    ./gnupg-agent.nix
    ./impermanence-extra.nix
    ./bluetooth.nix
    ./sabnzbd.nix
    ./tmux.nix
    ./printing.nix
    ./containers.nix
    ./clamav.nix
  ];
}
