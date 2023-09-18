#!/bin/bash

source ~/.thingworx.conf

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for existing of resource from a test Exstension
RESULT=$(./twx call -r AddCounting/GetAddNumbersWithLoop -ploopCount=1 -psecondNumber=2 -pfirstNumber=2)
if [ $? -ne 5 ]; then
    printf "${YELLOW}WARNING${NC}: Test extension is already exists\n"
fi

# Import an extension
RESULT=$(./twx import JavaExtension.zip)

if [ $? -ne 0 ]; then
    printf "Import extension - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi
# Call a resource to check if extension imported successfully
RESULT=$(./twx  call -r AddCounting/GetAddNumbersWithLoop -ploopCount=1 -psecondNumber=2 -pfirstNumber=2)

if [ $? -eq 5 ]; then
    printf "Call test extension resource - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi


# Import wrong extension
touch "Metadata.xml"
data="some test data..."
echo $data >"Metadata.xml"
mkdir "WrongFolder"
mv "Metadata.xml" "WrongFolder"

zip -r WrongFolder.zip WrongFolder

RESULT=$(./twx import WrongFolder.zip)

if [ $? -eq 0 ]; then
    printf "Import wrong exstension - ${RED}Fail${NC}\n"
    exit 1
fi

DELETE_EXT=$(curl -X POST -w '%{http_code}' "$TWX_URL/Subsystems/PlatformSubsystem/Services/DeleteExtensionPackage" \
    -H "X-XSRF-TOKEN: TWX-XSRF-TOKEN-VALUE" -H "AppKey: $TWX_APPKEY" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"packageName":"JavaExtension"}' \
    )

rm -r "WrongFolder"
rm -r "WrongFolder.zip"

printf "Test 4: Importing Extension - ${GREEN}Success${NC}\n"
