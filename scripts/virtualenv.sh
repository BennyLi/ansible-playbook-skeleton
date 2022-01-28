#! /usr/bin/env bash

check_python_installed() {
  if [ ! $(which python) ]; then
    error "You need to install python first!"
    info  "On Arch you can run 'sudo pacman -Sy python'"
    exit 1
  fi
}

setup_virtualenv() {
  check_python_installed

  if [ -f "${PYTHON_VIRTUAL_ENV_PATH}/bin/activate" ]; then
    info "Python virtual env ${BOLD}$PYTHON_VIRTUAL_ENV_NAME${RESET} already exits. ${YELLOW}SKIPPING${RESET}"
  else
    info "Setting up the Python virtual environment at '${PYTHON_VIRTUAL_ENV_PATH}' ..."
    python -m venv "$PYTHON_VIRTUAL_ENV_PATH"
  fi

  info "Activating Python virtual environment ${BOLD}$PYTHON_VIRTUAL_ENV_PATH${RESET} ..."
  . "${PYTHON_VIRTUAL_ENV_PATH}/bin/activate"

  info "Performing a ${BOLD}self upgrade for pip${RESET} inside the Python virtual environment ..."
  python -m pip install --upgrade pip > /dev/null
  export VIRTUAL_ENV="$PYTHON_VIRTUAL_ENV_PATH"
}
