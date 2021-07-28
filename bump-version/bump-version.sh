#!/bin/bash
SUFFIX="$1"

detectBuildTool(){
    build_tool="unknown"
	if [ -f "build.gradle" ]; then
		build_tool="gradle"
    elif [ -f "package.json" ]; then
		build_tool="node"
	elif [ -f "pom.xml" ]; then
		build_tool="maven"
	fi
}

getNextVersion(){
    local currentVersion="$1"
    if [ -z "$currentVersion" ]; then
        echo "Current version not set!"
        return 1
    fi
    echo "Version: $currentVersion"

    # Split out major version (X[.x.x])
    local majorpart="${currentVersion%%.*}"

    # Remove patch version and store temporary (X.x[.x])
    local tmppart="${currentVersion%.*}"

    # Split out minor version ([X.]x[.x])
    local minorpart="${tmppart##*.}"

    # Split out patch version ([X.x.]x)
    local patchpart="${currentVersion##*.}"

    # Create optional suffix
    if [[ "$SUFFIX" != "" ]]; then
        SUFFIX="-$SUFFIX"
    fi

    # Create next version by bumping minor version and zero-ing patch
    nextVersion="$majorpart.$((minorpart+1)).0$SUFFIX"
}

maven(){
    # Get version from pom
    local version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    getNextVersion $version

    # Update version in pom
    mvn versions:set -DnewVersion="$nextVersion" -q
}

node(){
    # Get version from node
    local version=$(cat package.json | jq -r '.version')
    getNextVersion $version

    # Update version in package.json
    silent=$(npm version $nextVersion)
}

gradle(){
    # Get version from pom
    # TODO getting version doesn't work here
    local version=$(gradle getVersion -q)
    getNextVersion $version

    # Update version in pom
    echo "version=$nextVersion" >> gradle.properties
}

detectBuildTool
if [ "$build_tool" == "maven" ]; then
	maven
elif [ "$build_tool" == "node" ]; then
	node
elif [ "$build_tool" == "gradle" ]; then
	gradle
else
	echo "No valid build tool detected. Options are maven or node"
fi


