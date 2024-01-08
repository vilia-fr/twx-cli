#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Upload sample file
file="$(dirname "$0")/test-upload-samples/test-upload.txt"

result=$(twx upload "SystemRepository/upload" "$file")
if [ $? -eq 6 ]; then
    printf "Upload service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Download test
result=$(twx download "SystemRepository/upload/test-upload.txt")
if [ $? -eq 7 ]; then
    printf "Download service - ${RED}Fail${NC}: $result\n"
    exit 1
    rm ./test-upload.txt
fi

printf "Test 6 - Upload-Download tests completed ${GREEN}successfully${NC}\n"
