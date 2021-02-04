# Get version from pom
version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

# Split out major version (X[.x.x])
majorpart="${version%%.*}"

# Remove patch version and store temporary (X.x[.x])
tmppart="${version%.*}"

# Split out minor version ([X.]x[.x])
minorpart="${tmppart##*.}"

# Split out patch version ([X.x.]x)
patchpart="${version##*.}"

# Create next version by bumping minor version and zero-ing patch
nextVersion="$majorpart.$((minorpart+1)).0-$1"

# Update version in pom
mvn versions:set -DnewVersion=$nextVersion -q


