#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

CHECK_REPOSITORY_COMMAND='twx call Things/SystemRepository/ListDirectories -ppath=/'
check_repository=$($CHECK_REPOSITORY_COMMAND)

DELETE_COMMAND='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-056987'

# Import a single XML file
result=$(twx import twx-test/single-entity-import.xml)
if [ $? -eq 2 ]; then
    delete_xml=$($DELETE_COMMAND)
    printf "Import service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a Thing string service
result=$(twx call Things/TMP-Thing-056987/TestService | jq .rows[0].result)
if [[ $result != '"success"' ]]; then
    delete_xml=$($DELETE_COMMAND)
    printf "Call string service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a Thing JSON service
result=$(twx call Things/TMP-Thing-056987/testJSON -ppar='{"aaa":"bbb"}')
if [[ $result != '{"aaa":"bbb"}' ]]; then
    delete_xml=$($DELETE_COMMAND)
    printf "Call JSON service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a Thing Infotable service
INFOTABLE_JSON='{"dataShape":{"fieldDefinitions":{"item":{"name":"item","aspects":{"isPrimaryKey":true},"description":"Item","baseType":"STRING","ordinal":0}}},"rows":[{"item":"yu1"}]}'
result=$(twx call Things/TMP-Thing-056987/testInfotable -ppar=$INFOTABLE_JSON | jq .rows[0].item)
if [[ $result != '"yu1"' ]]; then
    delete_xml=$($DELETE_COMMAND)
    printf "Call Infotable service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a resource service
result=$(twx call Resources/CurrentSessionInfo/GetDescription)
if [ $? -eq 5 ]; then
    printf "Call resource - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call wrong Thing service
result=$(twx call Things/SystemRepositoryy/GetProjectName)
if [ $? -eq 0 ]; then
    printf "Call service - ${RED}Fail${NC}\n"
    exit 1
fi

# Call wrong resource service
result=$(twx call Resources/CurrentSessionInfo/GetDescriptionn)
if [ $? -eq 0 ]; then
    printf "Call resource - ${RED}Fail${NC}\n"
    exit 1
fi

# Call wrong option
result=$(twx call -w SystemRepository/GetProjectName)
if [ $? -eq 0 ]; then
    printf "Call wrong option - ${RED}Fail${NC}\n"
    exit 1
fi

delete_xml==$($DELETE_COMMAND)

# Check delete of testing files
result=$(twx call Things/SystemRepository/ListDirectories -ppath=/)
if [[ "$result" != "$check_repository" ]]; then
    printf "Delete test entities - ${RED}Fail${NC}\n"
    exit 1
fi

printf "Test 1: Initial call tests completed ${GREEN}successfully${NC}\n"
