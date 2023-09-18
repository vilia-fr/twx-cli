#!/bin/bash

source ~/.thingworx.conf

RED='\033[0;31m'
GREEN='\033[0;32m'        
NC='\033[0m' # No Color

# Execute custom JS code
RESULT=$(./twx eval init.js -pname1=Value1)

if [ $? -ne 13 ]; then
    printf "Eval JS file - ${RED}Fail${NC}: $RESULT\n"
fi

# Execute custom JS code  with wrong param
RESULT=$(./twx eval init.js -pname12=Value1)

if [ $? -eq 0 ]; then
    printf "Eval JS file with wrong param - ${RED}Fail${NC}: $RESULT\n"
fi

# Execute custom JS code with wrong data in .js file
touch "wrongJS.js"
data="some wrond data ... "
cp "init.js" "wrongJS.js"
echo $data >>"wrongJS.js"

RESULT=$(./twx eval wrongJS.js -pname1=Value1)
if [ $? -eq 0 ]; then
    printf "Eval wrong JS file - ${RED}Fail${NC}: $RESULT\n"
fi


 rm -r "wrongJS.js"
printf "Test 5: Evaluating JS code - ${GREEN}Success${NC}\n"
