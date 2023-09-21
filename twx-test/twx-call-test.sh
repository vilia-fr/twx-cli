#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

CHECK_REPOSITORY_COMMAND='twx call Things/SystemRepository/ListDirectories -ppath=/'
CHECK_REPOSITORY=$($CHECK_REPOSITORY_COMMAND)

DELETE_COMMAND='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-056987'
# Import a single XML file
RESULT=$(twx import twx-test/single-entity-import.xml)

if [ $? -eq 2 ]; then
    DELETE_XML=$($DELETE_COMMAND)
    printf "Import service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call a string Thing service
RESULT=$(twx call Things/TMP-Thing-056987/TestService | jq .rows[0].result)
if [[ $RESULT != '"success"' ]]; then
    DELETE_XML==$($DELETE_COMMAND)
    printf "Call string service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call a THing JSON service
RESULT=$(twx call Things/TMP-Thing-056987/testJSON -ppar='{"aaa":"bbb"}')
if [[ $RESULT != '{"aaa":"bbb"}' ]]; then
    DELETE_XML==$($DELETE_COMMAND)
    printf "Call JSON service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call a resource service

RESULT=$(twx call Resources/CurrentSessionInfo/GetDescription)

if [ $? -eq 5 ]; then
    printf "Call resource - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call wrong Thing service
RESULT=$(twx call Things/SystemRepositoryy/GetProjectName)

if [ $? -eq 0 ]; then
    printf "Call service - ${RED}Fail${NC}\n"
    exit 1
fi

# Call wrong resource service
RESULT=$(twx call Resources/CurrentSessionInfo/GetDescriptionn)

if [ $? -eq 0 ]; then
    printf "Call resource - ${RED}Fail${NC}\n"
    exit 1
fi

# Call wrong option
RESULT=$(twx call -w SystemRepository/GetProjectName)

if [ $? -eq 0 ]; then
    printf "Call wrong option - ${RED}Fail${NC}\n"
    exit 1
fi

DELETE_XML==$($DELETE_COMMAND)

# Check delete of testing files
RESULT=$(twx call Things/SystemRepository/ListDirectories -ppath=/)

if [[ "$RESULT" != "$CHECK_REPOSITORY" ]]; then
    printf "Delete test entities - ${RED}Fail${NC}\n"
    exit 1
fi

printf "Test 1 - Initial call tests complited ${GREEN}successfully${NC}\n"
