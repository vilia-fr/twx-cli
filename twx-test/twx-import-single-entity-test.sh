#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

CHECK_REPOSITORY_COMMAND='twx call Things/SystemRepository/ListDirectories -ppath=/'
check_repository=$($CHECK_REPOSITORY_COMMAND)

DELETE_COMMAND='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-056987'

# Check for existing of service from test Thing
result=$(twx call Things/TMP-Thing-056987/TestService)
if [ $? -ne 5 ]; then
    printf "${YELLOW}WARNING${NC}: Test XML entitiy is already exists\n"
fi

# Import a single XML file
result=$(twx import twx-test/single-entity-import.xml)
if [ $? -eq 2 ]; then
    delete_xml==$($DELETE_COMMAND)
    printf "Import service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a service to check if XML imported successfully
result=$(twx call Things/TMP-Thing-056987/TestService)
if [ $? -eq 5 ]; then
    delete_xml==$($DELETE_COMMAND)
    printf "Call service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

delete_xml==$($DELETE_COMMAND)

# Import wrong data in XML file
result=$(twx import twx-test/single-wrong-entity-import.xml)

if [ $? -eq 0 ]; then
    printf "Import single XML - ${RED}Fail${NC}\n"
    exit 1
fi

delete_xml==$($DELETE_COMMAND)

# Check delete of testing files
result=$(twx call Things/SystemRepository/ListDirectories -ppath=/)

if [[ "$result" != "$check_repository" ]]; then
    printf "${YELLOW}WARNING${NC}: Test entities are not deleted\n"
fi

printf "Test 2: Importing XML entity - ${GREEN}Success${NC}\n"
