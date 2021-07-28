#!/bin/bash
source ./functions.sh

runTests(){
    for entry in "tests"/*
    do
    tmp=${entry#*/}   # remove prefix ending in "/"
    name=${tmp%.*}   # remove suffix starting with "."
    echo "Running tests for $name"
    source "./$entry" "$name"
    done
    printTestResults
}

#DEBUG=1
runTests