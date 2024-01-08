#!/bin/bash

#  TWX CLI - Unofficial ThingWorx command line utilities
#  Copyright (c) 2023 Geoffrey Espagne
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e

###########################################################################
################################ VARIABLES ################################
###########################################################################

readonly extension="Vilia.Utils.Exporter"

###########################################################################
############################## HELPER FUNCTIONS ###########################
###########################################################################

title() {
  echo
  echo "$1"
  echo
}

###############################################################################
################################ MAIN SEQUENCE ################################
###############################################################################

title "Uninstalling exporter utilities"

title "> Step 1: Deleting $extension"

result=$(twx call "Subsystems/PlatformSubsystem/DeleteExtensionPackage" -ppackageName="$extension")

if [ $? -ne 0 ]; then
    printf "Couldn't deleted extension - ${RED}Fail${NC}: $result\n"
    exit 1
fi

title "< Extension $extension deleted"

title "Exporter utilities successfully uninstalled"
