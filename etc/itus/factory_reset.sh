if [[ `df | grep -c overlay` == "1" ]]; then
	umount /overlay
fi
sleep 1        
mkdir -p /factory_reset
sleep 1                
mount /dev/mmcblk0p1 /factory_reset
sleep 1                            
cd /factory_reset                  
sleep 1                            
rm ItusrouterImage
sleep 5           
rm ItusbridgeImage
sleep 5           
rm ItusgatewayImage
sleep 5            
cp ItusrestoreImage ItusrouterImage
sleep 10                           
cp ItusrestoreImage ItusgatewayImage
sleep 10                            
cp ItusrestoreImage ItusbridgeImage 
sleep 10                            
cd /                               
sleep 1                            
umount /factory_reset
sleep 1              
umount -a            
sleep 1              
reboot -f
