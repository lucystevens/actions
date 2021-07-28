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
    # Get version
    VERSION=$( mvn help:evaluate -Dexpression=project.version -q -DforceStdout )
    echo "PROJECT_VERSION=$VERSION" >> "$GITHUB_ENV"

    # Get name/artifact
    ARTIFACT=$( mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout )
    echo "PROJECT_NAME=$ARTIFACT" >> "$GITHUB_ENV"

    # Get group
    GROUP=$( mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout )
    echo "PROJECT_GROUP=$GROUP" >> "$GITHUB_ENV"
}

node() {
    # Get version
    VERSION=$(node -e "console.log(require('./package.json').version);")
    echo "PROJECT_VERSION=$VERSION" >> "$GITHUB_ENV"

    # Get name
    NAME=$(node -e "console.log(require('./package.json').name);")
    echo "PROJECT_NAME=$NAME" >> "$GITHUB_ENV"
}

detectBuildTool
if [[ "$build_tool" == "maven" ]]; then
	maven
elif [[ "$build_tool" == "node" ]]; then
	node
else
	echo "No valid build tool detected. Options are maven or node"
fi