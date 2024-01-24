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

###########################################################################
################################ VARIABLES ################################
###########################################################################

readonly extension="Vilia.Utils.Exporter.zip"

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

title "Installing exporter utilities"

title "> Step 1: Importing $extension_name"

extension_name=$(basename $extension)
path="$(dirname "$0")/$extension"
result=$(twx import $path)

if [ $? -ne 0 ]; then
    printf "Import extension - ${RED}Fail${NC}: $result\n"
    exit 1
fi
title "< Extension $extension_name imported"

title "Exporter utilities successfully installed"
