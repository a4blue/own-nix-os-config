# Blocky
## Generate new SSL Cert
´´´
mkdir -p /nix/secret/blocky_cert/
openssl req -x509 -newkey ed25519 -days 3650 -noenc -keyout /nix/secret/blocky_cert/blocky.key -out /nix/secret/blocky_cert/blocky.crt -subj "/CN=blocky.homelab.internal"
´´´