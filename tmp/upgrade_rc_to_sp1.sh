#!/bin/sh
#
################################################################################################
# Purpose    Updates the factory restore image to the latest version (1.51 SP1)                #
# File name  Upgrade_RC_to_151SP1                                                              #
#                                                                                              #
# VERSION NUMBER 3 - Last Modified date Feb 24th 2016 by Hans                                  #
#                                                                                              #
# Hans       V3 - Changes to the update() function - now updates all images                    #
# Hans       V2 - Updated version using a dropbox account to source the restore image          #
# ITUS       V1 - Original version (Nov 2015) using an ITUS file server                        #
#                                                                                              #
#                                                                                              #
#                                                                                              #
# When changing the script please update WHAT YOU CHANGED OR ADDED, ADD 1 TO THE VERSION       #
# NUMBER AND DATE CHANGED.                                                                     #
# This will make it easier to time to come to identify what your you have and who did what.    #
################################################################################################

# Mount location for the factory restore images
RESTORE_PART=/dev/mmcblk0p1
MOUNT=/overlay

# Links to dropbox files
URL_IMG="https://www.dropbox.com/s/xes9mhm6ylkmdkz/ItusrestoreImage?dl=1"
URL_MD5="https://www.dropbox.com/s/gittxfbuscg838m/md5sum.txt?dl=1"

# List of file names to download
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
#       curl -o /tmp/md5sum ${URL}md5sum -k
        curl -L -o /tmp/md5sum $URL_MD5 -k
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
				# curl -o ${MOUNT}/updates/$file ${URL}$file -k
                curl -L -o ${MOUNT}/updates/$file $URL_IMG -k	
                        [[ "$?" != "0" ]] && echo "Unable to download $file!  Aborting firmware updates." && error
        done

		echo "Validating downloads ...."
		for file in `find ${MOUNT}/updates/ -type f`; do
				CHECKSUM=""
				CHECKSUM=`md5sum $file | awk '{print $1}'`
				[[ -z "`grep ${CHECKSUM} /tmp/md5sum`" ]] && echo "Validation of downloaded updates failed! Aborting ...." && error
		done
}

update(){
        echo "Updating ...."
		if [ -f ${MOUNT}/updates/ItusrestoreImage ]; then
			cp -v ${MOUNT}/updates/ItusrestoreImage /overlay/ItusrestoreImage		# local backup
			cp -v ${MOUNT}/updates/ItusrestoreImage /overlay/ItusrouterImage		# updates router image
			cp -v ${MOUNT}/updates/ItusrestoreImage /overlay/ItusbridgeImage		# updates bridge image
			cp -v ${MOUNT}/updates/ItusrestoreImage /overlay/ItusgatewayImage		# updates gateway image
		fi
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
download_updates					# use this option to download the file from itusnetworks.net
update
cleanup



