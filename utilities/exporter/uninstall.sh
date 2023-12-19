#!/bin/bash

set -e

###########################################################################
################################ VARIABLES ################################
###########################################################################
extension="Vilia.Utils.Exporter"

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

uninstall_exporter_extention() { 
  title "> Deleting extension $1"
  local result=$(twx call \
    "Subsystems/PlatformSubsystem/DeleteExtensionPackage" \
    -ppackageName="$1")

  if [ $? -ne 0 ]; then
      printf "Couldn't deleted extension - ${RED}Fail${NC}: $result\n"
      exit 1
  fi
  
  title "< Extension $1 uninstalled"
}

###############################################################################
################################ MAIN SEQUENCE ################################
###############################################################################

title "Will uninstall exporter utilities"

title "Step 1: Deleting $extension"
uninstall_exporter_extention $extension

title "Exporter utilities successfully uninstalled"
