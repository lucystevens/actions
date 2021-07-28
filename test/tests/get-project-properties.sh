#!/bin/bash
testGetGradleName(){
    gradleSetup "testGetGradleName"
    version=$(gradle getName -q)
    assertEquals "actions-gradle-test" $version
    teardown
}

testGetMavenProperties(){
    mavenSetup "testGetMavenProperties"
    runActionScript get-project-properties

    assertGithubEnvHas "PROJECT_VERSION" "1.2.3-SNAPSHOT"
    assertGithubEnvHas "PROJECT_NAME" "actions-maven-test"
    assertGithubEnvHas "PROJECT_GROUP" "uk.co.lukestevens"

    teardown
}

#testGetGradleName
#testGetMavenProperties