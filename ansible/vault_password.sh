#!/bin/bash
# Retrieves vault password from 1Password using the op CLI
# Requires: 1Password CLI (op) authenticated session
PASSWORD=$(op read "op://Network/Ansible Vault/password" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "${PASSWORD}" ]; then
  echo "ERROR: Could not retrieve vault password from 1Password" >&2
  exit 1
fi

echo "${PASSWORD}"