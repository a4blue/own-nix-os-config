# Set up new Nitrokey

## Set Pin
If not already done, the FIDO2 PIN should be set with ```nitropy fido2 set-pin```
## Generate new keys
Generate resident keys ```ssh-keygen -t ed25519-sk -O resident -O application="ssh:HomeNet"```
Copy keys to local machine ```ssh-keygen -K```
Output will be ./id_ed25519_sk_rk_HomeNet