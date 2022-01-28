#! /bin/bash

################################################################################
#
# Formatting options
# See also
#   * https://linux.101hacks.com/ps1-examples/prompt-color-using-tput/
#
################################################################################

BOLD="$(tput bold)"
RESET="$(tput sgr0)"


#
# Color options
#
  fromhex(){
      hex=${1#"#"}
      r=$(printf '0x%0.2s' "$hex")
      g=$(printf '0x%0.2s' ${hex#??})
      b=$(printf '0x%0.2s' ${hex#????})
      printf '%03d' "$(( (r<75?0:(r-35)/40)*6*6 +
                         (g<75?0:(g-35)/40)*6   +
                         (b<75?0:(b-35)/40)     + 16 ))"
  }

  RED="$(tput setaf 160)"     # HEX color: #e31414
  YELLOW="$(tput setaf 178)"  # HEX color: #c9ad0a
  BLUE="$(tput setaf 033)"    # HEX color: #0a99fc


################################################################################
#
# Logging helper
#
################################################################################

info()        { echo -e    "${BLUE}> [INFO]${RESET}   $*"; }
info_wait()   { echo -e -n "${BLUE}> [INFO]${RESET}   $* ..."; }
info_done()   { echo -e    "${BLUE} [${1:-DONE}]${RESET}"; }
warn()        { echo -e    "${YELLOW}! [WARN]   $*${RESET}"; }
error()       { echo -e    "${RED}X [ERROR]  🚨 $* 🚨${RESET}"; }
error_done()  { echo -e    "${RED} [$1]${RESET}"; }
errexit()     { error "$*"; exit 1; }
