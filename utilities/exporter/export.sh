#!/bin/bash

set -e

###########################################################################
################################ VARIABLES ################################
###########################################################################
is_windows=0
log_prefix="Export"
unzip_utility=""
twx_url="$TWX_PROTOCOL://$TWX_HOST:$TWX_PORT/Thingworx"

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

###########################################################################
################################ FUNCTIONS ################################
###########################################################################

export_sources() {
  local folder="$1"
  local helper_thing="$2"
  local twx_folder=$folder

  #TODO: what is twx_folder variable?

  #TODO: will throw an error if trying to delete a folder that doesn't exist in repo
  title "Export step 1: Cleanup remote SRC folder"
  twx call \
    "Things/SystemRepository/DeleteFolder" \
    -ppath="/${twx_folder}"

  title "Export step 2: Export sources"
  twx call \
    "Things/$helper_thing/ExportSources" \
    -pexportPath="/${twx_folder}"
    # -pexportPath="/${twx_folder}/twx-src"

  title "Export step 3: Zip sources"
  twx call \
    'Things/SystemRepository/CreateZipArchive' \
    -ppath="/${twx_folder}/" \
    -pnewFileName="twx-src.zip" \
    -pfiles="/${twx_folder}"

  title "Export step 4: Download sources"
  twx download \
    'SystemRepository/twx-src.zip'

  title "Export step 5: Extract sources"
  rm -rf ./tmp/
  $unzip_utility twx-src.zip -d ./tmp/
  rm twx-src.zip

  title "Export step 6: Cleanup local sources"
  rm -rf "$folder/twx-src"

  title "Export step 7: Copy sources"
  cp -rf "tmp/${twx_folder}" "./twx-src"
  rm -rf ./tmp/

  if [ $is_windows -eq "1" ]; then
    title "Export step 8: Convert line endings from UNIX to WINDOWS"
    find "$folder" -type f -print0 |xargs -0 util/unix2dos/unix2dos -q
  fi
}

###############################################################################
################################ MAIN SEQUENCE ################################
###############################################################################

title "Will export from $twx_url"

title "Step 1. Check OS"
check_OS

if [ $is_windows -eq "1" ]; then
  echo "WINDOWS OS detected"
  unzip_utility="util/unzip/unzip"
else
  echo "UNIX-like OS detected"
  if ! command -v unzip &> /dev/null
  then
      echo "unzip could not be found"
      exit
  fi
  unzip_utility="unzip"
fi

# title "Step 3: Check AppKey access"
# check_access_method

export_folder_name="twx-src"
export_thing="Test_TG"
title "Export entities"
export_sources "$export_folder_name" "$export_thing"

title "Export completed successfully"
