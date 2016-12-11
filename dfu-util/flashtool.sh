#!/bin/bash

VERSION=$(cat version.txt)

source include_linux.sh

wget -q --spider $VERSION_CHECK_URL

if [ ! $? = "0" ]; then
	echo "********************************************************************************"
	echo "********************************************************************************"
	echo "********************************************************************************"
	echo "********************************************************************************"
	echo "WARNING, THIS IS NOT THE LATEST VERSION!!!!"
	echo "You have 10 seconds to abort this script!"
	echo "Get the latest version at"
	echo "$VERSION_UPDATE_URL"
	echo "********************************************************************************"
	echo "********************************************************************************"
	echo "********************************************************************************"
	echo "********************************************************************************"
fi

# ensure that binary is executable which may depend on the way it has been extracted from archive
chmod +x ./dfu-util_linux_amd64/dfu-util

./dfu-util_linux_amd64/dfu-util $DFUUTIL_COMMANDLINE

echo "****************************"
echo "* F E R T I G !            *"
echo "****************************"

read -n1 -r -p "Press any key to continue..." key
