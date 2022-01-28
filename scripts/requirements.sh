#! /usr/bin/env bash

check_host_requirements() {
  info "Checking host requirments ..."

  command -v docker >/dev/null || errexit "Please install docker first!"
}

install_requirements() {
  install_base_requirements
  install_python_requirements
  install_ansible_requirements
}

install_base_requirements() {
  info "Installing ${BOLD}base requirements${RESET} (like ansible itself) in the virtual env"
  python -m pip install -r "$PROJECT_ROOT/requirements_python.txt" >/dev/null
}

install_python_requirements() {
  info "Collection Python requirements ..."
  echo "" > "${PROJECT_ROOT}/requirements_roles_python.yml"
  for requirement_file in $(get_all_python_requirement_files); do
    cat "$requirement_file" >> "${PROJECT_ROOT}/requirements_roles_python.yml"
  done

  info "Installing python requirements for all roles ..."
  pip install -r "${PROJECT_ROOT}/requirements_roles_python.yml" >/dev/null
}

install_ansible_requirements() {
  local all_requirement_files=""

  info "Collection Ansible requirements (Ansible Galaxy collections) ..."
  for requirement_file in $(get_all_ansible_requirement_files); do
    all_requirement_files="${all_requirement_files} /mnt/${requirement_file}"
  done

  info "Putting all requirements into one file ..."
  local requirements_list="$(
    docker run \
      -it \
      --rm \
      -v "$ANSIBLE_ROLES:/mnt:ro" \
      -e REQUIREMENT_FILES="$all_requirement_files" \
      alpine \
        /bin/sh -c "\
          apk add --no-cache yq >/dev/null
          yq eval '.collections' \
            "\$REQUIREMENT_FILES" \
            --no-colors \
            --no-doc \
          | sed --regexp-extended 's/^/  /g'
        "
  )"
  cat > "${PROJECT_ROOT}/requirements_roles_ansible.yml" <<REQUIREMENTS
---

collections:
$requirements_list
REQUIREMENTS

  info "Installing ansible requirements for all roles ..."
  ansible-galaxy collection install                                      \
    --upgrade                                                            \
    --requirements-file "${PROJECT_ROOT}/requirements_roles_ansible.yml" \
    > /dev/null
}

function get_all_python_requirement_files() {
  find "$ANSIBLE_ROLES" -name 'requirements_python.txt' -printf '%P\n'
}

function get_all_ansible_requirement_files() {
  find "$ANSIBLE_ROLES" -name 'requirements_ansible.yml' -printf '%P\n'
}

