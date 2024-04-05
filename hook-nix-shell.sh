#! /bin/bash

if [ ! -f ~/.config/sops/age/keys.txt ] 
then 
  ll ~/.config/sops/age/keys.txt
  export SOPS_AGE_KEY_FILE="$PWD/key.unlocked.txt"
  age -d key.age > $SOPS_AGE_KEY_FILE
fi
