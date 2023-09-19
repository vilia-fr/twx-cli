#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

DELETE_COMMAND_ONE='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-097897'
DELETE_COMMAND_TWO='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-087634'

# Check for existing of service from test Things

ENTITY_ONE=$(twx call Things/TMP-Thing-097897/TestService1)
RESULT_ENTITY_ONE=$?
ENTITY_TWO=$(twx call Things/TMP-Thing-087634/TestService2)
RESULT_ENTITY_TWO=$?

if [ $RESULT_ENTITY_ONE -ne 5 ] || [ $RESULT_ENTITY_TWO -ne 5 ]; then
    printf "${YELLOW}WARNING${NC}: Test XML entitiy is already exists\n"
fi

# Import a test folder

RESULT=$(twx import twx-test/test-folder-xml)

if [ $? -ne 0 ]; then
    $DELETE_COMMAND_ONE >/dev/null
    $DELETE_COMMAND_TWO >/dev/null
    printf "Import folder - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call a service to check if first XML imported successfully
RESULT=$(twx call Things/TMP-Thing-097897/TestService1)

if [ $? -eq 5 ]; then
    $DELETE_COMMAND_ONE >/dev/null
    $DELETE_COMMAND_TWO >/dev/null
    printf "Call first service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi
# Call a service to check if second XML imported successfully
RESULT=$(twx call Things/TMP-Thing-087634/TestService2)
if [ $? -eq 5 ]; then
    $DELETE_COMMAND_ONE >/dev/null
    $DELETE_COMMAND_TWO >/dev/null
    printf "Call second service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Import a directory with wrong XML file

RESULT=$(twx import twx-test/test-folder-wrong-xml)

if [ $? -eq 0 ]; then
    rm -r "TestWrongXML.xml"
    printf "Import wrong folder XML - ${RED}Fail${NC}\n"
    exit 1
fi

$DELETE_COMMAND_ONE >/dev/null
$DELETE_COMMAND_TWO >/dev/null

printf "Test 3: Importing XML folder - ${GREEN}Success${NC}\n"
