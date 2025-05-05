# Unlock Bcachefs error
If encountering the ENOKEY error the following helps
´´´
nix-shell -p keyutils
keyctl new_session
keyctl link @u @s
´´´