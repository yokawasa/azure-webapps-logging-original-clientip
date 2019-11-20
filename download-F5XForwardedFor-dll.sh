#!/bin/sh

WGET_COMMNAD="wget"
UNZIP_COMMNAD="unzip"

if ! type "$WGET_COMMNAD" > /dev/null; then
    echo "$WGET_COMMNAD command doesn't exist! Please install wget here"
    exit 0
fi
if ! type "$UNZIP_COMMNAD" > /dev/null; then
    echo "$UNZIP_COMMNAD command doesn't exist! Please install unzip here"
    exit 0
fi

echo "Getting copy of F5XForwardedFor.zip from F5 download center...."
ZIPFILE="F5XForwardedFor.zip"
F5URL="https://cdn.f5.com/websites/devcentral.f5.com/downloads/F5XForwardedFor.zip"
wget -O ${ZIPFILE} ${F5URL}

if [ ! -f ${ZIPFILE} ]
then
    echo "${ZIPFILE} does not exist as the package download failure(?)!!"
    exit 1
fi

echo "Unzip the package and extract a 32 bit DLL from the package"
unzip ${ZIPFILE}
if [ ! -f F5XForwardedFor2008/x86/Release/F5XForwardedFor.dll ]
then
    echo "Failed to extract the dll!! Please check the package inside"
    exit 1
fi
mv F5XForwardedFor2008/x86/Release/F5XForwardedFor.dll ISAPIFilters/
rm -rf F5XForwardedFor2008 ${ZIPFILE}

echo "Success!! >>> ISAPIFilters/F5XForwardedFor.dll" 
exit 0
