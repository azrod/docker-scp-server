#!/bin/bash
set -euo pipefail

SECRETS_FILE=/run/secrets/authorized_keys
DATA_USER=data
DATA_DIR=/home/data
HOST_KEYS_DIR_PREFIX=/var/local
HOST_KEYS_DIR="$HOST_KEYS_DIR_PREFIX/etc/ssh"

# This won't be executed if keys already exist (i.e. from a volume)
mkdir -p "$HOST_KEYS_DIR"
ssh-keygen -A -f "$HOST_KEYS_DIR_PREFIX"

if [[ -n "${AUTHORIZED_KEYS_BASE64:-}" ]]; then
  # Copy authorized keys from ENV variable
  echo "$AUTHORIZED_KEYS_BASE64" | base64 -d >>"$AUTHORIZED_KEYS_FILE"
elif [[ -n "${AUTHORIZED_KEYS:-}" ]]; then
  # Copy authorized keys from ENV variable
  echo "$AUTHORIZED_KEYS" >>"$AUTHORIZED_KEYS_FILE"
elif [[ -f "$SECRETS_FILE" ]]; then
  cp "$SECRETS_FILE" "$AUTHORIZED_KEYS_FILE"
else
  >&2 echo "Error! Missing AUTHORIZED_KEYS variable or file in /run/secrets/authorized_keys."
  exit 1
fi

writeable="1"
grep "$DATA_DIR" /proc/mounts | grep " rw" || writeable=""
if [[ -n "$writeable" ]]; then
  # Chown data folder (if mounted as a volume for the first time)
  if [[ "$(stat -c %U:%G "$DATA_DIR")" != "$DATA_USER:$DATA_USER" ]]; then
    >&2 echo Changing owner of "$DATA_DIR" to "$DATA_USER:$DATA_USER"
    chown "$DATA_USER":"$DATA_USER" "$DATA_DIR"
  fi
fi

# Run sshd on container start
exec /usr/sbin/sshd -D -e
