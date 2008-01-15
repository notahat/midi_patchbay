#!/bin/sh
cd "${BUILD_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}"

# Clean out any CVS directories that have accidentally been included
find . -name CVS -type d -exec rm -r {} \;

# This cleans out any headers that were copied to our binary
find . -name Headers -type d -exec rm -r {} \;
find . -name Headers -exec rm {} \;

# Redo the prebinding on our app after stripping...this doesn't seem to work, so I've commented it out for now
#cd Contents/MacOS
#redo_prebinding -e "${PWD}" "${PRODUCT_NAME}"
