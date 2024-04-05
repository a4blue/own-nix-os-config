{ pkgs ? import <nixpkgs> {} }: 
pkgs.mkShell {
  packages = with pkgs; [
    age
    sops
  ];

  shellHook = ''
  . hook-nix-shell.sh
  trap \
    "
      rm -f key.unlocked.txt
    " \
  EXIT
  echo "Use 'sops updatekeys secrets/secrets.yaml' to add new keys after adding in .sops.yaml"
  '';
}