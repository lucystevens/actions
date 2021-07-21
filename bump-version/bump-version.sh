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
    # Split out major version (X[.x.x])
    majorpart="${version%%.*}"

    # Remove patch version and store temporary (X.x[.x])
    tmppart="${version%.*}"

    # Split out minor version ([X.]x[.x])
    minorpart="${tmppart##*.}"

    # Split out patch version ([X.x.]x)
    patchpart="${version##*.}"

    # Create optional suffix
    suffix="$1"
    if [[ "$suffix" != "" ]]; then
        suffix="-$suffix"
    fi

    # Create next version by bumping minor version and zero-ing patch
    nextVersion="$majorpart.$((minorpart+1)).0$suffix"
}

maven(){
    # Get version from pom
    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    getNextVersion

    # Update version in pom
    mvn versions:set -DnewVersion=$nextVersion -q
}

node(){
    # Get version from node
    version=$(node -e "console.log(require('./package.json').version);")
    getNextVersion

    # Update version in package.json
    npm version $nextVersion
}

detectBuildTool
if [[ "$1" == "maven" ]]; then
	maven
elif [[ "$1" == "node" ]]; then
	node
else
	echo "No valid build tool detected. Options are maven or node"
fi


