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

HOST=$1

CLIENT_CERTIFICATE_FILE=$(mktemp -p /dev/shm/)
echo $2 | base64 -d > $CLIENT_CERTIFICATE_FILE

CLIENT_KEY_FILE=$(mktemp -p /dev/shm/)
echo $3 | base64 -d > $CLIENT_KEY_FILE

CLUSTER_CA_CERTIFICATE_FILE=$(mktemp -p /dev/shm/)
echo $4 | base64 -d > $CLUSTER_CA_CERTIFICATE_FILE

NULL_KUBECONFIG=$(mktemp -p /dev/shm/)

touch $NULL_KUBECONFIG

n=0
until [ "$n" -ge 6 ]
do
   kubectl --kubeconfig $NULL_KUBECONFIG --server $HOST --client-certificate $CLIENT_CERTIFICATE_FILE --client-key $CLIENT_KEY_FILE --certificate-authority $CLUSTER_CA_CERTIFICATE_FILE -n vault wait --for=condition=Ready pod/vault-0 --timeout=600s &> /dev/null
   RETVAL=$?
   if [ $RETVAL -eq 0 ]; then
      break
   fi
   n=$((n+1))
   sleep 15
done

rm -f $CLIENT_CERTIFICATE_FILE
rm -f $CLIENT_KEY_FILE
rm -f $CLUSTER_CA_CERTIFICATE_FILE
rm -f $NULL_KUBECONFIG

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
