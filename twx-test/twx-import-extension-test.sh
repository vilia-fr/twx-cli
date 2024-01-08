#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for existing of resource from a test Extension
result=$(twx call Resources/AddCounting/GetAddNumbersWithLoop -ploopCount=1 -psecondNumber=2 -pfirstNumber=2)
if [ $? -ne 5 ]; then
    printf "${YELLOW}WARNING${NC}: Test extension already exists\n"
fi

# Import an extension
result=$(twx import twx-test/JavaExtension.zip)
if [ $? -ne 0 ]; then
    printf "Import extension - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Call a resource to check if extension imported successfully
result=$(twx call Resources/AddCounting/GetAddNumbersWithLoop -ploopCount=1 -psecondNumber=2 -pfirstNumber=2)

if [ $? -eq 5 ]; then
    printf "Call test extension resource service - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Import wrong extension
result=$(twx import twx-test/twx-test-wrong-data-ext.zip)

if [ $? -eq 0 ]; then
    printf "Import wrong exstension - ${RED}Fail${NC}\n"
    exit 1
fi

# Delete test extension
delete_ext=$(twx call "Subsystems/PlatformSubsystem/DeleteExtensionPackage" -ppackageName="JavaExtension")

printf "Test 4: Importing Extension - ${GREEN}Success${NC}\n"
