#!/bin/bash

set -e

###########################################################################
################################ VARIABLES ################################
###########################################################################

extension="Vilia.Utils.Exporter.zip"
extension_name=$(basename $extension)

###########################################################################
############################## HELPER FUNCTIONS ###########################
###########################################################################

title() {
  echo
  echo "$1"
  echo
}

###########################################################################
################################ FUNCTIONS ################################
###########################################################################

install_exporter_extention() { 
  title "> Importing $1"
  local path="$(dirname "$0")/$1"
  local result=$(twx import $path)
  #echo "$RESULT"
  if [ $? -ne 0 ]; then
      printf "Import extension - ${RED}Fail${NC}: $result\n"
      exit 1
  fi
  title "< $1 imported"
}

###############################################################################
################################ MAIN SEQUENCE ################################
###############################################################################

title "Will install exporter utilities"

title "Step 1: Importing $extension_name"
install_exporter_extention $extension

title "Exporter utilities successfully installed"
