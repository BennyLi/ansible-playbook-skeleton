#! /usr/bin/env bash

set -o posix
set -o nounset
set -o errexit
set -o pipefail


################################################################################
#
# Variables
#
################################################################################

ANSIBLE_PLAYBOOK_PATH="${HOME}/.ansible_playbook"
ANSIBLE_PLAYBOOK_REPO="git@github.com:BennyLi/ansible-playbook-skeleton.git"

ANSIBLE_ROLES_PATH="${HOME}/.ansible_roles"
ANSIBLE_ROLES_REPO="git@github.com:BennyLi/ansible-roles.git"

ANSIBLE_CONFIG_PATH="${HOME}/.ansible_config"
ANSIBLE_CONFIG_REPO=""

#
# Some Colors for logging to stdout
#
  BOLD="$(tput bold)"
  RESET="$(tput sgr0)"
  RED="$(tput setaf 160)"     # HEX color: #e31414
  YELLOW="$(tput setaf 178)"  # HEX color: #c9ad0a
  BLUE="$(tput setaf 033)"    # HEX color: #0a99fc



################################################################################
#
# Helper functions
#
################################################################################

info()        { echo -e    "${BLUE}> [INFO]${RESET}   $*"; }
info_wait()   { echo -e -n "${BLUE}> [INFO]${RESET}   $* ..."; }
info_done()   { echo -e    "${BLUE} [${1:-DONE}]${RESET}"; }
warn()        { echo -e    "${YELLOW}! [WARN]   $*${RESET}"; }
error()       { echo -e    "${RED}X [ERROR]  🚨 $* 🚨${RESET}"; }
error_done()  { echo -e    "${RED} [$1]${RESET}"; }
errexit()     { error "$*"; exit 1; }

get_ansible_playbook() {
  if [ ! -d "$ANSIBLE_PLAYBOOK_PATH" ]; then
    info "Cloning Ansible playbook skeleton repo to ${BOLD}${ANSIBLE_PLAYBOOK_PATH}${RESET} ..."
    git clone "$ANSIBLE_PLAYBOOK_REPO" "$ANSIBLE_PLAYBOOK_PATH"
  else
    info "Folder for the ${BOLD}Ansible playbook skeleton repo${RESET} already present. ${YELLOW}Skipping!${RESET}"
  fi
}

get_ansible_roles() {
  if [ ! -d "$ANSIBLE_ROLES_PATH" ]; then
    info "Cloning Ansible roles repo to ${BOLD}${ANSIBLE_ROLES_PATH}${RESET} ..."
    git clone "$ANSIBLE_ROLES_REPO" "$ANSIBLE_ROLES_PATH"
  else
    info "Folder for the ${BOLD}Ansible roles repo${RESET} already present. ${YELLOW}Skipping!${RESET}"
  fi
}

get_ansible_config() {
  if [ ! -d "$ANSIBLE_CONFIG_PATH" ]; then
    info "Cloning Ansible config repo to ${BOLD}${ANSIBLE_CONFIG_PATH}${RESET} ..."
    git clone "$ANSIBLE_CONFIG_REPO" "$ANSIBLE_CONFIG_PATH"
  else
    info "Folder for the ${BOLD}Ansible config repo${RESET} already present. ${YELLOW}Skipping!${RESET}"
  fi
}

setup_ansible_cfg() {
  if [ ! -e "${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg" ]; then
    info "Configuring ansible.cfg file ..."
    cp "${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg.default" "${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg"
    sed --in-place --regexp-extended "s|inventory =.*|inventory = ${ANSIBLE_CONFIG_PATH}/inventory.yml|g" "${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg"
    sed --in-place --regexp-extended "s|roles_path =.*|roles_path = ${ANSIBLE_ROLES_PATH}|g" "${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg"
    chmod u=r,g=r,o= "${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg"
  else
    info "The configuration file ${BOLD}${ANSIBLE_PLAYBOOK_PATH}/ansible.cfg${RESET} is already present. ${YELLOW}Skipping!${RESET}"
  fi
}



################################################################################
#
# -----  MAIN  -----
#
################################################################################

get_ansible_playbook
get_ansible_roles
get_ansible_config

setup_ansible_cfg
