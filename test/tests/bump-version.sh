#!/bin/bash
TEST_SUITE="$1"

maven_noSuffix(){
    copyMavenFiles
    runActionScript bump-version
    assertExpectedFileEquals "pom.xml"
}

maven_withSuffix(){
    copyMavenFiles
    runActionScript bump-version "SNAPSHOT"
    assertExpectedFileEquals "pom.xml"
}

node_noSuffix(){
    copyNodeFiles
    runActionScript bump-version
    assertExpectedFileEquals "package.json"
}

node_withSuffix(){
    copyNodeFiles
    runActionScript bump-version "beta"
    assertExpectedFileEquals "package.json"
}

gradle_noSuffix(){
    copyGradleFiles
    runActionScript bump-version
    assertEquals "1.1.0" $(cat gradle.properties)
}

gradle_withSuffix(){
    copyGradleFiles
    runActionScript bump-version "SNAPSHOT"
    assertEquals "1.1.0-SNAPSHOT" $(cat gradle.properties)
}

test maven_noSuffix
test maven_withSuffix
test node_noSuffix
test node_withSuffix
test gradle_noSuffix
test gradle_withSuffix