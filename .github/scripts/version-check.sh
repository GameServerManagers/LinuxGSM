#!/bin/bash
version=$(grep "version=" linuxgsm.sh | sed -e 's/version//g' | tr -d '="')
modulesversion=$(grep "modulesversion=" lgsm/modules/core_modules.sh | sed -e 's/modulesversion//g' | tr -d '="')

if [ "${version}" != "${modulesversion}" ]; then
	echo "Error! LinuxGSM version mismatch"
	echo "Version: ${version}"
	echo "Modules Version: ${modulesversion}"
	exit 1
else
	echo "Success! LinuxGSM version match"
	echo "Version: ${version}"
	echo "Modules Version: ${modulesversion}"
	exit
fi
