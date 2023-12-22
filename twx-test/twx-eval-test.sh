#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

CHECK_REPOSITORY_COMMAND='twx call Things/SystemRepository/ListDirectories -ppath=/'
check_repository=$($CHECK_REPOSITORY_COMMAND)

# Execute custom JS code
result=$(twx eval twx-test/test-eval.js -pname1=Value1  | jq .rows[0].result)
if [ $result -ne 13 ]; then
    printf "Eval JS file - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Execute custom JS code  with wrong param
result=$(twx eval twx-test/test-eval.js -pname12=Value1)
if [ $? -ne 5 ]; then
    printf "Eval JS file with wrong param - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Execute custom JS code with wrong data in .js file
result=$(twx eval test-wrong-data.js -pname1=Value1)
if [ $? -ne 5 ]; then
    printf "Eval wrong JS file - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Execute custom JS code using pipe
result=$(echo "result=1+2;" | twx eval - | jq .rows[0].result)
if [ $result -ne 3 ]; then
    printf "Eval wrong JS file - ${RED}Fail${NC}: $result\n"
    exit 1
fi

# Check delete of testing files
result=$(twx call Things/SystemRepository/ListDirectories -ppath=/)
if [[ "$result" != "$check_repository" ]]; then
    printf "${YELLOW}WARNING${NC}: Test entities are not deleted\n"
fi

printf "Test 5: Evaluating JS code - ${GREEN}Success${NC}\n"
