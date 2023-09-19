#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

DELETE_COMMAND='twx call Resources/EntityServices/DeleteThing -pname=TMP-Thing-056987'

# Check for existing of service from test Thing
RESULT=$(twx call Things/TMP-Thing-056987/TestService)

if [ $? -ne 5 ]; then
    printf "${YELLOW}WARNING${NC}: Test XML entitiy is already exists\n"
fi

# Import a single XML file
RESULT=$(twx import twx-test/single-entity-import.xml)

if [ $? -eq 2 ]; then
    DELETE_XML==$($DELETE_COMMAND)
    printf "Import service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call a service to check if XML imported successfully
RESULT=$(twx call Things/TMP-Thing-056987/TestService)

if [ $? -eq 5 ]; then
    DELETE_XML==$($DELETE_COMMAND)
    printf "Call resource - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

DELETE_XML==$($DELETE_COMMAND)

# Import empty file
touch "TestWrongXML.xml"
RESULT=$(twx import TestWrongXML.xml)

if [ $? -eq 0 ]; then
    printf "Import single XML - ${RED}Fail${NC}\n"
    exit 1
fi

# Import wrong data in XML file
data="some test data..."
echo $data >"TestWrongXML.xml"
RESULT=$(twx import TestWrongXML.xml)

if [ $? -eq 0 ]; then
    printf "Import single XML - ${RED}Fail${NC}\n"
    exit 1
fi

rm -r "TestWrongXML.xml"
printf "Test 2: Importing XML entity - ${GREEN}Success${NC}\n"
