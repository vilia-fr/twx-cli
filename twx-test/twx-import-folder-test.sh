#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

CHECK_REPOSITORY_COMMAND='twx call Things/SystemRepository/ListDirectories -ppath=/'
check_repository=$($CHECK_REPOSITORY_COMMAND)

DELETE_COMMAND_ONE='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-097897'
DELETE_COMMAND_TWO='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-087634'

# Check for existing of service from test Things
entity_one=$(twx call Things/TMP-Thing-097897/TestService1)
result_entity_one=$?
entity_two=$(twx call Things/TMP-Thing-087634/TestService2)
result_entity_two=$?

if [ $result_entity_one -ne 5 ] || [ $result_entity_two -ne 5 ]; then
    printf "${YELLOW}WARNING${NC}: Test XML entitiy is already exists\n"
fi

# Import a test folder
result=$(twx import twx-test/test-folder-xml)
if [ $? -ne 0 ]; then
    $DELETE_COMMAND_ONE >/dev/null
    $DELETE_COMMAND_TWO >/dev/null
    printf "Import folder - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a service to check if first XML imported successfully
result=$(twx call Things/TMP-Thing-097897/TestService1)
if [ $? -eq 5 ]; then
    $DELETE_COMMAND_ONE >/dev/null
    $DELETE_COMMAND_TWO >/dev/null
    printf "Call first service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a service to check if second XML imported successfully
result=$(twx call Things/TMP-Thing-087634/TestService2)
if [ $? -eq 5 ]; then
    $DELETE_COMMAND_ONE >/dev/null
    $DELETE_COMMAND_TWO >/dev/null
    printf "Call second service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Import a directory with wrong XML file
result=$(twx import twx-test/test-folder-wrong-xml)
if [ $? -eq 0 ]; then
    printf "Import wrong folder XML - ${RED}Fail${NC}\n"
    exit 1
fi

$DELETE_COMMAND_ONE >/dev/null
$DELETE_COMMAND_TWO >/dev/null

# Check delete of testing files
result=$(twx call Things/SystemRepository/ListDirectories -ppath=/)
if [[ "$result" != "$check_repository" ]]; then
    printf "${YELLOW}WARNING${NC}: Test entities are not deleted\n"
fi

printf "Test 3: Importing XML folder - ${GREEN}Success${NC}\n"
