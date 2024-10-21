# Install
see install.sh

## Notes
- Nextcloud needs some manual love

## SOPS
get the age Key and add it to ```.sops.yaml```
and run ```nix-shell```. **Note to myself:** Your PGP Key is the final backup, take good care of it 🙂

# TODO's

## General
- move from nix-shell to nix shell (flakeify shell)
- move homelab configurations to homelab folder and therefore unpollute the modules folder
- common configuration/modules for nixOs / home-manager should be developed afterwards

## Gaming
- develop a PoC on laptop

## Hardening
- Secure Boot
- Limit Local Login possibility
- Rate Limit ssh Logins

## More Features
### General
- Use Case for TPM2 ?
  - ssh host key on TPM for remote disk unlock to prevent MITM-Attack by reading boot partition ? Secure Boot needs to be also enabled for this to work
- "Automatic" updates ? Github build pipeline ?
### Local Network Only
- Jellyfin ?
- Stash ?
- Jellyseerrr ?
- Servarr ?
- Sabnzbd ?
- Mealie ?
- tdarr ?

### Public Network
- Some sensible Site

## Cleanup
- Generally cleanup the code to be more readable
- sops keys need some cleanup, also the secrets
- sops secrets rename to camelCase

# Housekeeping

## Self-signed Certs
````
nix-shell -p openssl
cd /persistent/var/lib/self-signed-nginx-cert
openssl ecparam -genkey -name secp521r1 -out homelab-local-root.key
openssl req -new -key homelab-local-root.key -out csr-wildcard-homelab-local.pem
openssl req -x509 -nodes -days 365 -key homelab-local-root.key -in csr-wildcard-homelab-local.pem -out wildcard-homelab-local.pem
chmod 600 /persistent/var/lib/self-signed-nginx-cert/*
chown nginx:nginx /persistent/var/lib/self-signed-nginx-cert/*
````

# Noteworthy Stuff
- Using encrypted bcachefs with remote unlock
- borgbackup with bcachefs subvolume snapshot
- Impermanence with bcachefs via systemd Service on boot
