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

maven() {
    # Get version from pom
    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

    # Remove suffix if exists
    finalversion=${version%%-*}

    # Update version in pom
    mvn versions:set -DnewVersion=$finalversion -q
}

node() {
    # Get version from node
    version=$(node -e "console.log(require('./package.json').version);")

    # Remove suffix if exists
    finalversion=${version%%-*}

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