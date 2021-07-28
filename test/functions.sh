#!/bin/bash
TESTS_RUN=0
TESTS_FAILED=0
CURRENT_TEST_FAILED=0
NL=$'\n'
FAILED_TEST_NAMES="${NL}Failed tests:"
BASEDIR=$(realpath ../)
DEBUG=0

setup(){
    TESTS_RUN=$(($TESTS_RUN + 1))
    export CURRENT_TEST=$1
    CURRENT_TEST_FAILED=0
    mkdir "$BASEDIR/test/tmp"
    touch "$BASEDIR/test/tmp/github.env"
    export GITHUB_ENV="$BASEDIR/test/tmp/github.env"
    cd "$BASEDIR/test/tmp"
}

copyTemplateFile(){
    cp "$BASEDIR/test/templates/$1" "$BASEDIR/test/tmp/$1"
}

runActionScript(){
    bash "$BASEDIR/$1/$1.sh" "${@:2}"
}

echoerr() { printf "%s\n" "$*" >&2; }

debug(){
    if [ "$DEBUG" != "0" ]; then
        echo "$@"
    fi
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

getGithubEnv() {
    grep "${1}" "$GITHUB_ENV"|cut -d'=' -f2
}

copyGradleFiles(){
    copyTemplateFile build.gradle
    copyTemplateFile settings.gradle
    copyTemplateFile gradle.properties
}

copyMavenFiles(){
    copyTemplateFile pom.xml
}

copyNodeFiles(){
    copyTemplateFile package.json
}

fail(){
    echoerr "$CURRENT_TEST failed. $1"

    # Only increment the failure counter on the first fail
    if [ "$CURRENT_TEST_FAILED" == "0" ]; then
        FAILED_TEST_NAMES="$FAILED_TEST_NAMES${NL}$CURRENT_TEST"
        TESTS_FAILED=$(($TESTS_FAILED + 1))
        CURRENT_TEST_FAILED=1
    fi
}

assertEquals(){
    if [ "$1" != "$2" ]; then
      fail "Expected $1 but was $2"
    fi
}

assertGithubEnvHas(){
    local value=$(getGithubEnv "$1")
    assertEquals "$2" "$value"
}

# Overloaded version of 'assertFilesEqual' that uses the 
# current test name to get the expected file.
assertExpectedFileEquals(){
    assertFilesEqual "$BASEDIR/test/expected/$CURRENT_TEST" "$1"
}

assertFilesEqual(){
    debug "Asserting files: $1=$2"
    local lineNumber=1
    while IFS="" read -r expectedLineRaw || [ -n "$expectedLineRaw" ]
    do
        local actualLineRaw=$(sed -n "$lineNumber"p $2)
        local actualLine=$(trim "$actualLineRaw")
        local expectedLine=$(trim "$expectedLineRaw")
        if [ "$expectedLine" != "$actualLine" ]; then
            fail "Error at L$lineNumber:$2. Expected '$expectedLine' but was '$actualLine'"
            return
        fi
        lineNumber=$((lineNumber + 1))
    done < "$1"
}

teardown(){
    debug "Removing tmp folder"
    cd "$BASEDIR/test"
    rm -rf "$BASEDIR/test/tmp"
}

printTestResults(){
    if [ "$TESTS_FAILED" != "0" ]; then
        echoerr "${NL}Test failed: $TESTS_FAILED/$TESTS_RUN"
        echoerr $FAILED_TEST_NAMES
        exit 1
    else
        TESTS_PASSED=$(($TESTS_RUN - $TESTS_FAILED))
        echo "Tests passed $TESTS_PASSED/$TESTS_RUN"
        echo "All tests passed!"
        exit 1
    fi
}

test(){
    local test="$1"
    debug "Setting up test $test"
    setup "$TEST_SUITE/$test"
    debug "Running test $test"
    $test
    teardown
}