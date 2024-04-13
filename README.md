# Install
see install.sh

## Notes
- Nextcloud needs some manual love
- Need to test paperless and photoprism if it is now declarerative

## Tailscale
tailscale up
tailscale cert <domain-name>

## SOPS
get the age Key and add it to ```.sops.yaml```
and run ```nix-shell```. **Note to myself:** Your PGP Key is the final backup, take good care of it 🙂

# TODO's

## Tailscale
- Automate Certs
- ssh ? (also remote unlock ?)

## Hardening
- Secure Boot
- Limit Local Login possibility
- Rate Limit ssh Logins

## More Features
### General
- Duplicati (probably not, evaluating borgbackup for now)
- Use Case for TPM2 ?
- "Automatic" updates ? Github build pipeline ?
- Authentik ? (usefull if more users) or Authelia ?
### Local Network Only
- Jellyfin ?
- Stash ?
- Jellyseerrr ?
- Servarr ?
- Sabnzbd ?
- Mealie ?
- tdarr ?

### Tailscale Network
- Journalctl Viewer
- Service Health checks ?

### Public Network
- Some sensible Site
- Nextcloud shares ? (Nextclod share links working through public network, but everything else is still behind tailscale)

## Cleanup
Generally cleanup the code to be more readable

# Noteworthy Stuff
- Using encrypted bcachefs with remote unlock
- borgbackup with bcachefs subvolume snapshot
- Impermanence with bcachefs via systemd Service on boot
- new tailscale cert on boot for nginx