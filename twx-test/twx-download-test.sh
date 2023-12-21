#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# TODO: first load a file to download it
# TODO: Should also make an import function to mirror download

# Download test
RESULT=$(twx download SystemRepository/GES_sandbox.zip)
if [ $? -eq 6 ]; then
    printf "Download service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

printf "Test 6 - Download tests completed ${GREEN}successfully${NC}\n"
