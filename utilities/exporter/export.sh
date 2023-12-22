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

#!/bin/bash

set -e

###########################################################################
################################ VARIABLES ################################
###########################################################################
twx_url="$TWX_PROTOCOL://$TWX_HOST:$TWX_PORT/Thingworx"

readonly remote_export_folder="src"
readonly export_thing="Vilia.Utils.Exporter_TG"
readonly export_repository="SystemRepository"

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

title "Will export from :"
twx config

title "Export entities"

title "Export step 1: Cleanup remote SRC folder"
set +e
twx call "Things/$export_repository/DeleteFolder" -ppath="/${remote_export_folder}"
set -e

title "Export step 2: Export sources"
twx call "Things/$export_thing/ExportSources" -prepository"${export_repository}" -ppath="/${remote_export_folder}"

title "Export step 3: Zip sources"
twx call "Things/$export_repository/CreateZipArchive" -ppath="/" -pnewFileName="twx-src.zip" -pfiles="/${remote_export_folder}"

title "Export step 4: Download sources"
twx download "$export_repository/twx-src.zip"

title "Export step 5: Extract sources"
rm -rf ./tmp/
unzip "twx-src.zip" -d "./tmp/"
rm twx-src.zip

title "Export step 6: Cleanup local sources"
rm -rf "./twx-src"

title "Export step 7: Copy sources"
mv "tmp/${remote_export_folder}/" "."
mv "${remote_export_folder}" "twx-src"
rm -rf ./tmp/

title "Export completed successfully"
