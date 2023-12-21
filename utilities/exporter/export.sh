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
is_windows=0
log_prefix="Export"
unzip_utility=""
twx_url="$TWX_PROTOCOL://$TWX_HOST:$TWX_PORT/Thingworx"

readonly export_thing="Vilia.Utils.Exporter_TG"
readonly export_folder_name="twx-src"
readonly export_repository="SystemRepository"

###########################################################################
############################## HELPER FUNCTIONS ###########################
###########################################################################

title() {
  echo
  echo "$1"
  echo
}

check_OS() {
  is_windows=0
  case "$OSTYPE" in
    win*)     is_windows=1 ;;
    msys*)    is_windows=1 ;;
    cygwin*)  is_windows=1 ;;
  esac
}

###############################################################################
################################ MAIN SEQUENCE ################################
###############################################################################

title "Will export from $twx_url"

title "Step 1. Check OS"
check_OS

if [ $is_windows -eq "1" ]; then
  echo "WINDOWS OS detected"
  unzip_utility="util/unzip/unzip" # replace by zip xxx
else
  echo "UNIX-like OS detected"
  if ! command -v unzip &> /dev/null
  then
      echo "unzip could not be found"
      exit
  fi
  unzip_utility="unzip"
fi

title "Export entities"

title "Export step 1: Cleanup remote SRC folder"
twx call "Things/$export_repository/DeleteFolder" -ppath="/${export_folder_name}"

title "Export step 2: Export sources"
twx call "Things/$export_thing/ExportSources" -prepository"${export_repository}" -ppath="${export_folder_name}"

title "Export step 3: Zip sources"
twx call "Things/$export_repository/CreateZipArchive" -ppath="/" -pnewFileName="twx-src.zip" -pfiles="/${export_folder_name}"

title "Export step 4: Download sources"
twx download "$export_repository/twx-src.zip"

title "Export step 5: Extract sources"
rm -rf ./tmp/
$unzip_utility "twx-src.zip" -d "./tmp/"
rm twx-src.zip

title "Export step 6: Cleanup local sources"
rm -rf "$folder/twx-src"

title "Export step 7: Copy sources"
cp -rf "tmp/${export_folder_name}" "./twx-src"
rm -rf ./tmp/

# TODO: remove
if [ $is_windows -eq "1" ]; then
  title "Export step 8: Convert line endings from UNIX to WINDOWS"
  find "$folder" -type f -print0 |xargs -0 util/unix2dos/unix2dos -q
fi

title "Export completed successfully"
