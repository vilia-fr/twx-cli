#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m' 
NC='\033[0m' # No Color

# Call a service

RESULT=$(twx call Things/SystemRepository/GetProjectName)

if [ $? -eq 5 ]; then
    printf "Call service - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call a resource
RESULT=$(twx call Resources/CurrentSessionInfo/GetDescription)

if [ $? -eq 5 ]; then
    printf "Call resource - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Call wrong service
RESULT=$(twx call Things/SystemRepositoryy/GetProjectName)

if [ $? -eq 0 ]; then
    printf "Call service - ${RED}Fail${NC}\n"
    exit 1
fi

# Call wrong resource
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

printf "Test 1 - Initial call tests complited ${GREEN}successfully${NC}\n"
