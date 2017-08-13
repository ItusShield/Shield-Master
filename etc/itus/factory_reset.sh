#############################################################################
# Version 1                                                                 #
# Allows a factory reset to occur from either gui or running this command   #
# from the command line.                                                    #
# Called by: from gui or command line                                       #
#############################################################################

if [[ `df | grep -c overlay` == "1" ]]; then
	umount /overlay
fi
sleep 1
     echo " Making new Directory"

mkdir -p /factory_reset
sleep 1
      echo " mount factory_reset directory"
mount /dev/mmcblk0p1 /factory_reset
sleep 1

cd /factory_reset
sleep 1
   echo "removing router image"
rm ItusrouterImage
sleep 5
    echo "removing bridge image"
rm ItusbridgeImage
sleep 5
    echo "removing gateway image"
rm ItusgatewayImage
sleep 5
     echo "copying new router image"
cp ItusrestoreImage ItusrouterImage
sleep 15
     echo "copying new router image"
cp ItusrestoreImage ItusgatewayImage
sleep 15
     echo "copying new router image"
cp ItusrestoreImage ItusbridgeImage
sleep 15

cd /
echo " waiting 10 second, you may get messages that certain devices are busy"
echo " and the display stops working,  a reboot has been started"
echo " and the shield is updating itself, this can take upto 10 minutes, "
echo " the screen will not be updated so go and have a cup of tea."
echo " default password is itus"
sleep 10
umount /factory_reset
sleep 1
umount -a
sleep 1
reboot -f
