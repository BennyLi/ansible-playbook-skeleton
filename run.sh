#! /usr/bin/env bash

#
# See https://kvz.io/bash-best-practices.html for some best practices I use
#

set -o posix
set -o errexit
set -o pipefail
set -o nounset

# Only when debugging
#set -o xtrace


################################################################################
#
# Variables
#
################################################################################

source ./variables.env

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

INVENTORY=""
PLAYBOOK="${ANSIBLE_CONFIG_PATH}/playbook.yml"
ADDTIONAL_PLAYBOOKS=""
#ANSIBLE_CONFIG="$(sed --regexp-extended --silent 's/')"
ANSIBLE_CONFIG_FILE="${PROJECT_ROOT}/ansible.cfg"
ANSIBLE_INVENTORY="${ANSIBLE_CONFIG_PATH}/inventory.yml"
ANSIBLE_ARGS=""

VAULT_PASSWORD_FILE="${PROJECT_ROOT}/.vault_pass"

################################################################################
#
# Functions
#
################################################################################

source "${PROJECT_ROOT}/scripts/logging.sh"
source "${PROJECT_ROOT}/scripts/virtualenv.sh"
source "${PROJECT_ROOT}/scripts/requirements.sh"


print_usage() {
  cat <<USAGE
Usage:
  $0 [-p <additional-playbook-file>] [-t <tag-name>]...

Known devices are [ $(get_list_of_known_devices) ]
Known task tags are: [ $(get_list_of_known_tags) ]

Arguments:
  -h   --help        Show this help message.
  -p   --playbook    Add another playbook file to the execution chain.

All command line arguments accepted by the ansible-playbook command can be provided. They will be passed through.
One example could be to limit the execution to one specific machine by specifing
  ${BOLD}--limit <machine-name-from-inventory>${RESET}
USAGE
}

get_list_of_known_devices() {
  ansible all                          \
    --inventory "$ANSIBLE_INVENTORY"   \
    --list-hosts                       \
  | tr --delete '\n'                   `# Remove newlines`              \
  | tr --squeeze-repeats ' '           `# Remove unneeded whitespaces`  \
  | cut --delimiter ':' --field 2      `# Extract device/host names`    \
  | sed 's|^[[:blank:]]*||g'           `# Remove leading whitespace`
}

get_list_of_known_tags() {
  ansible-playbook                                \
    --inventory "$ANSIBLE_INVENTORY"              \
    --list-tags                                   \
    "$PLAYBOOK" $ADDTIONAL_PLAYBOOKS              \
    2>/dev/null                                   \
  | grep "TASK TAGS"                              \
  | cut --delimiter "[" --field 2                 \
  | cut --delimiter "]" --field 1                 \
  | tr '\n' ','                                   `# Replace newlines`                \
  | sed 's/,,/, /g'                               `# Replace double commas`           \
  | sed --regexp-extended 's/,([a-zA-Z])/, \1/g'  `# Add missing spaces after commas` \
  | sed 's/,$//g'                                 `# Remove ascending comma`
}

handle_arguments() {
  if [ $# -le 1 ]; then
    error "You must atleast provide a            machine to provision!"
    print_usage
    exit 1
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        print_usage
        exit 0
        ;;
      -i|-m|--inventory|--machine)
        shift
        [ ! -z "$INVENTORY" ] && INVENTORY="${INVENTORY},"
        INVENTORY="${INVENTORY}${1}"
        shift
        ;;
      -p|--playbook)
        shift
        ADDTIONAL_PLAYBOOKS="${ADDTIONAL_PLAYBOOKS} ${1}"
        shift
        ;;
      *)
        ANSIBLE_ARGS="${ANSIBLE_ARGS} ${1}"
        shift
        ;;
    esac
  done
}

add_vault_pass_file_arg() {
  if [ -f "$VAULT_PASSWORD_FILE" ]; then
    ANSIBLE_ARGS="${ANSIBLE_ARGS} --vault-password-file ${VAULT_PASSWORD_FILE}"
  else
    echo "Password file not found!"
    exit 3
  fi
}




################################################################################
#
# -----  MAIN  -----
#
################################################################################

check_host_requirements
setup_virtualenv

install_requirements

handle_arguments "$@"
add_vault_pass_file_arg
info "I will provision these machines: ${INVENTORY}"
info "Passing '${ANSIBLE_ARGS}' as arguments to the ansible-playbook command ..."

info "Executing the Ansible playbook ..."
ansible-playbook \
  --ask-become-pass \
  --inventory "${INVENTORY:-$ANSIBLE_INVENTORY}" \
  --extra-vars user_name_from_env="$(id --user --name)" \
  --extra-vars user_group_from_env="$(id --group --name)" \
  --extra-vars user_shell_from_env="$(echo $SHELL | sed -En 's/.*\/(\w*)/\1/p')" \
  --extra-vars dockerfiles_path="$DOCKERFILES_PATH" \
  --extra-vars public_dotfiles_path="$PUBLIC_DOTFILES_PATH" \
  ${ANSIBLE_ARGS} \
  ${PLAYBOOK} ${ADDTIONAL_PLAYBOOKS}
