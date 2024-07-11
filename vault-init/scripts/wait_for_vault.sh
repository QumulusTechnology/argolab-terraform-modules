#!/bin/bash

## Usage: wait_for_vault.sh
## Is used to wait for vault to be ready before configuring vault.
## Designed not to fail if vault is not ready, but to return a status message.
## Used by the vault-init module.
## will retry 6 times with 15 second intervals before giving up.
## also waits 10 seconds after vault is ready to make sure it is fully ready.
## and outputs a json object with the following fields:
## message: a message describing the status
## status: true if vault is ready, false if not
## skip_tls_verify which is just used to ensure the vault provider waits for vault to be ready before trying to connect to it.

n=0
until [ "$n" -ge 6 ]
do
   kubectl -n vault wait --for=condition=Ready pod/vault-0 --timeout=600s &> /dev/null
   RETVAL=$?
   if [ $RETVAL -eq 0 ]; then
      break
   fi
   n=$((n+1))
   sleep 15
done

if [ $RETVAL -ne 0 ]; then
  jq -n \
    --arg m "vault is not ready" \
    --arg s false \
    --arg stv true \
    '{"message": $m, "status": $s,  "skip_tls_verify": $stv}'
else
  sleep 10
  jq -n \
    --arg m "vault is ready" \
    --arg s true \
    --arg stv true \
    '{"message": $m, "status": $s,  "skip_tls_verify": $stv}'
fi
