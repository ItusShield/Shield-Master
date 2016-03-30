#!/bin/sh
#
# This script updates Shield from RC1 / BETA to 1.51SP1. It asumes that source files are available on itusnetworks.net
# If this is not the case, update the URL or copy the images directly to Shield temp folder
#
#
RESTORE_PART=/dev/mmcblk0p1
MOUNT=/overlay
URL="https://api.itusnetworks.net/free/v1/ITUS-BETA?file="
#UPDATES="ItusrestoreImage router.tar.gz"
#RESET_FILES="ItusrestoreImage router.tar.gz"
UPDATES="ItusrestoreImage"
RESET_FILES="ItusrestoreImage"

error(){
        echo "Shield Update Failed - Please try again and if issues persist please contact support (https://itus.io/support/#Help)"
        exit 1
}

mount_filesystem(){
        [[ -n "`mount | grep ${MOUNT}`" ]] && umount $MOUNT > /dev/null 2>&1
                mkdir -p ${MOUNT}
        if [ -z "`mount | grep ${MOUNT}`" ]; then
                mount -o rw $RESTORE_PART $MOUNT
                [[ "$?" != "0" ]] && echo "Unable to mount restore partition! Aborting ...." && error
        fi
}

download_updates() {
        echo "Fetching md5sums ...."
        curl -o /tmp/md5sum ${URL}md5sum -k
        [[ "$?" != "0" ]] && echo "Unable to download new md5sums! Aborting ...." && error
        sed -i '/^$/d' /tmp/md5sum

                echo "Downloading updates ...."
        mkdir -p ${MOUNT}/updates
        for file in $UPDATES
        do
                echo "Downloading: $file"
				#
				# This line below downloads the file
				#
                curl -o ${MOUNT}/updates/$file ${URL}$file -k
                        [[ "$?" != "0" ]] && echo "Unable to download $file!  Aborting firmware updates." && error
        done

                echo "Validating downloads ...."
                for file in `find ${MOUNT}/updates/ -type f`; do
                        CHECKSUM=""
                        CHECKSUM=`md5sum $file | awk '{print $1}'`
                        [[ -z "`grep ${CHECKSUM} /tmp/md5sum`" ]] && echo "Validation of downloaded updates failed! Aborting ...." && error
                done
}

copy_updates() {
		# ASSUMPTION/WARNING
		#
		# Itusrestoreimage and md5sum.txt are stored in the /tmp/updates folder
		# WinSCP (or similar) is used to copy the image to this folder before starting the upgrade.
		#
        mkdir -p ${MOUNT}/updates
        echo "Copying updates ...."
		cp /tmp/updates/* ${MOUNT}/updates
        echo "Validating downloads ...."
        for file in `find ${MOUNT}/updates/ -type f`; do
			CHECKSUM=""
            CHECKSUM=`md5sum $file | awk '{print $1}'`
            [[ -z "`grep ${CHECKSUM} /tmp/updates/md5sum.txt`" ]] && echo "Validation of copied updates failed! Aborting ...." && error
		done
}



update(){
        echo "Updating ...."
        [[ -f ${MOUNT}/updates/ItusrestoreImage ]] && cp -v /overlay/updates/ItusrestoreImage /overlay/ItusrestoreImage && cp -v /overlay/updates/ItusrestoreImage /overlay/ItusrouterImage
        [[ -f ${MOUNT}/updates/router.tar.gz ]] && cp -v /overlay/updates/router.tar.gz /overlay/restore/router.tar.gz
        echo "FIRMWARE DOWNLOAD COMPLETE, PLEASE RUN A FACTORY RESET TO COMPLETE UPGRADE" >> /tmp/snort/alert.fast
}

cleanup(){
        rm -f /tmp/md5sum
        rm -rf /overlay/updates/*
        umount $MOUNT
        echo "FIRMWARE DOWNLOAD COMPLETE, PLEASE REBOOT YOUR SHIELD TO COMPLETE THE UPGRADE."
        echo "****THE UPGRADE PROCESS WILL TAKE ABOUT 10 MINUTES TO COMPLETE*****."
	echo "WARNING: DO NOT DISCONNECT POWER FROM YOUR SHIELD DURING THE UPGRADE"
}

mount_filesystem
# download_updates                      # use this option to download the file from itusnetworks.net
copy_updates                            # use this option when the image is already stored locally in /tmp/updates
update
cleanup

