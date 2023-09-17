#!/bin/bash -e

if [ -z "$1" ]; then
    echo "Usage: $0 version-tag"
    exit 1
fi

VERSION="$1"
REPO_URL="git@github.com:mpartel/bindfs"

umask 0022

# We work in a temporary dir to avoid interference
# of the autotools files in the parent dir.
OUTPUTDIR=`pwd`
TMPDIR="/tmp/bindfs-build"
rm -Rf $TMPDIR
mkdir $TMPDIR
pushd "$TMPDIR"

# Download the release source
git clone "$REPO_URL" "bindfs-$VERSION"

# Prepare the source tree:
# - check out the release tag
# - remove .git
# - run autotools
pushd "bindfs-$VERSION"
git checkout "$VERSION"
rm -Rf .git
./autogen.sh
rm -Rf autom4te.cache
popd

# Make the source package
tar cvzf "bindfs-${VERSION}.tar.gz" "bindfs-$VERSION"

# Get the change log and man-page
mkdir -p ./docs
cp "bindfs-$VERSION/ChangeLog" ./docs/ChangeLog.utf8.txt
cp "bindfs-$VERSION/src/bindfs.1" ./docs/bindfs.1

# Create the HTML man page
rman -f HTML -r "" docs/bindfs.1 > docs/bindfs.1.html

# Compile the source
pushd "bindfs-$VERSION"
./configure
make
popd

# Get the bindfs --help text
"bindfs-$VERSION/src/bindfs" --help > docs/bindfs-help.txt

# Copy products to original dir
cp -r "bindfs-$VERSION.tar.gz" \
      docs \
      "$OUTPUTDIR/"

# Clean up and we're done
popd
rm -Rf $TMPDIR

echo
echo "DONE!"
echo

