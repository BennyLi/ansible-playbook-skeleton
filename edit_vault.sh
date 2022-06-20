#! /usr/bin/env bash

set -o posix
set -o nounset
set -o pipefail
set -o errexit

# TODO
# - Vault command

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "${PROJECT_ROOT}/variables.env"
source "${PROJECT_ROOT}/scripts/logging.sh"

#
# Setup the Python virtualenv for Ansible
#
  source "${PROJECT_ROOT}/scripts/virtualenv.sh"
  setup_virtualenv


#
# Some pre-processing things
#
  #
  # Setup vault command parameters
  #
    CMD_PARAMS=""
    if test -e "${ANSIBLE_PLAYBOOK_PATH}/.vault_pass"
    then
      CMD_PARAMS="${CMD_PARAMS} --vault-password-file "${ANSIBLE_PLAYBOOK_PATH}/.vault_pass""
    fi

#
# Get the list of vault files from the config dir
# and provide the list to choose from to the user.
#
  ANSIBLE_VAULT_FILE_LIST="/tmp/ansible-vault-file-list.txt"
  echo "CREATE A NEW VAULT" > "${ANSIBLE_VAULT_FILE_LIST}"
  grep --recursive --files-with-matches 'ANSIBLE_VAULT' "${ANSIBLE_CONFIG_PATH}" >> "${ANSIBLE_VAULT_FILE_LIST}"

  echo "Please select which vault you want to edit:"
  nl "${ANSIBLE_VAULT_FILE_LIST}"

  count="$(wc --lines "${ANSIBLE_VAULT_FILE_LIST}" | cut --field 1 --delimiter ' ')"
  selection=""
  while true; do
    read -p 'Select a vault file: ' selection
    # If the user selection is an integer between one and $count...
    if [ "$selection" -eq "$selection" ] && [ "$selection" -gt 0 ] && [ "$selection" -le "$count" ]; then
      break
    fi
  done

  if [ "$selection" -eq 1 ]; then
    read -p "Where to store the new vault file? If relative path given, will be stored in ${ANSIBLE_CONFIG_PATH} " vault
    if [[ $vault != /* ]]; then
      vault="${ANSIBLE_CONFIG_PATH}/${vault}"
    fi
    info "Will create a new vault file at '${vault}'"
    exit 2
    CMD_PARAMS="create $CMD_PARAMS"
  else
    vault="$(sed -n "${selection}p" ${ANSIBLE_VAULT_FILE_LIST})"
    CMD_PARAMS="edit $CMD_PARAMS"
  fi

  info "Selected the vault '$vault'"
  rm "${ANSIBLE_VAULT_FILE_LIST}"

#
# Let's go
#
  ansible-vault $CMD_PARAMS "$vault"
