#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'        
NC='\033[0m' # No Color

# Execute custom JS code
RESULT=$(twx eval twx-test/test-eval.js -pname1=Value1)

if [ $? -ne 13 ]; then
    printf "Eval JS file - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Execute custom JS code  with wrong param
RESULT=$(twx eval twx-test/test-eval.js -pname12=Value1)

if [ $? -eq 0 ]; then
    printf "Eval JS file with wrong param - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

# Execute custom JS code with wrong data in .js file
RESULT=$(twx eval test-wrong-data.js -pname1=Value1)
if [ $? -eq 0 ]; then
    printf "Eval wrong JS file - ${RED}Fail${NC}: $RESULT\n"
    exit 1
fi

printf "Test 5: Evaluating JS code - ${GREEN}Success${NC}\n"
