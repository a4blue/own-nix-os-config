# Bcachefs
## Unlock Bcachefs error
If encountering the ENOKEY error the following helps
´´´
nix-shell -p keyutils
keyctl new_session
keyctl link @u @s
´´´
## Label existing Device
´´´
echo {desired label} > /sys/fs/bcachefs/{bcachefs uuid}/dev-0/label
´´´