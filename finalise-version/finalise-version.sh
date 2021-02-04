# Get version from pom
version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

# Remove suffix if exists
finalversion=${version%%-*}

# Update version in pom
mvn versions:set -DnewVersion=$finalversion -q