#!bin/sh

# Script by Roadrunner42

MODE_FILE='/.shield_mode'
SHIELD_MODE='Unknown'
DISK_PARTITION='Unknown'


if [ -r $MODE_FILE ]; then
	rm $MODE_FILE
fi

# Create file

# Detect disk partition
# 	if  [ `df -h | grep -m1 mmcblk* | awk '{ print substr( $0, 6, 14 )  }'` ]; then
		DISK_PARTITION=`df -h | grep -m1 mmcblk* | awk '{ print substr( $0, 6, 14 ) }'`
# 	fi
# Determnine shield mode
	if   [ $DISK_PARTITION = 'mmcblk0p2' ]; then
		SHIELD_MODE='Router'
	elif [ $DISK_PARTITION = 'mmcblk0p3' ]; then
		SHIELD_MODE='Gateway'
	elif [ $DISK_PARTITION == 'mmcblk0p4' ]; then
		SHIELD_MODE='Bridge'
	else
		echo "Shield operation error"
	fi

echo $SHIELD_MODE > $MODE_FILE
# echo ""
# cat $MODE_FILE
