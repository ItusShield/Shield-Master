#!/bin/sh                                                                        

. /usr/share/libubox/jshn.sh
PRIVATE_ADDRESS="^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)"
                                                                                 
get_gateway()                                                                    
{                                                                                
        GATEWAY=`ip route show default | grep default | awk '{print $3}' | uniq` 
        if [  `echo "$GATEWAY" | grep -E $PRIVATE_ADDRESS` ]           
        then                                                                     
                echo $GATEWAY                                                    
        else                                                                     
                echo None                                                        
        fi                                                                               
}                                                                                
                                                                                 
get_ip()                                                                         
{                                                                                
        IP_REGEX="inet [0-9]\+\.[0-9]\+\.[0-9]\+\."                              
        IP=`ip addr show br-lan | grep -o "${IP_REGEX}" | grep -o [0-9].* | uniq`
        if [ `echo $IP | grep -E $PRIVATE_ADDRESS` ]                      
        then                                                                    
                echo $IP                                               
        else                                                           
                echo None                                                       
        fi                                                             
}                                                                      
                                                                       
/etc/init.d/vnstat enable && /etc/init.d/vnstat start && sleep 1       
                                                                       
# Enable cron                                                         
/etc/init.d/cron enable && /etc/init.d/cron start && sleep 1          
                                                                      
# Enable firmware upgrade                                             
/etc/init.d/fwupgrade enable && /etc/init.d/fwupgrade start && sleep 1
                                                                      
# Restart firewall                                                    
/etc/init.d/firewall restart && sleep 1                               
                                                                      
# Get br-lan protocol status
json_load "$(ubus call network.interface.lan status)"
json_get_var protocol proto
if [ "$protocol" == "dhcp" ]
then
	while true                                                            
	do                                                                    
		# Get gateway and dhcp leased address
	        gateway=$(get_gateway)                                        
	        dhcp_leased_ip=$(get_ip)                                                 
	        if [ "$gateway" != "None" ] && [ "$dhcp_leased_ip" != "None" ]           
	        then                                                          
		
			# Get current ip address information
	               	ip_address=`ip addr show br-lan | grep $dhcp_leased_ip | awk '{ print $2 }'` 
			netmask=`ipcalc.sh $ip_address | grep NETMASK | cut -d'=' -f2`
			broadcast=`ipcalc.sh $ip_address | grep BROADCAST | cut -d'=' -f2`
	                static_ip=`echo $dhcp_leased_ip | sed 's/$/111/'`                      

			# Setup lan ip address
		        uci set network.lan.proto=static
		        uci set network.lan.ipaddr=$static_ip
		        uci set network.lan.netmask=$netmask
			uci set network.lan.gateway=$gateway
			uci set network.lan.broadcast=$broadcast
			uci set network.lan.dns=$gateway
		        uci commit
			ifup lan
			
			# wait for lan interface to come up
			sleep 10
	                break                                                 
	        fi                                                            
	        sleep 1                                                       
	done                                                                  
	logger -t "itus-setup" -s "Set lan ip address to ${static_ip}"
fi

sh /etc/itus/ituswebfilter.sh update
sleep 10
for i in `tail -n 3 /tmp/resolv.conf.auto | grep nameserver`; do
if [ -z "`cat /etc/resolv.conf | grep "$i"`" ]; then
echo "nameserver $i" >> /etc/resolv.conf
fi
done    

sleep 1
ethtool -s eth0 autoneg off
sleep 1
ethtool -s eth0 autoneg on
sleep 1
ethtool -s eth1 autoneg off
sleep 1
ethtool -s eth1 autoneg on
sleep 1
ethtool -s eth2 autoneg off
sleep 1
ethtool -s eth2 autoneg on
sleep 1

# Remove line from rc.local                                                
if grep 'Can be safely removed' /etc/rc.local; then                        
        sed -i '/next few lines/d' /etc/rc.local                           
        sed -i '/Can be safely removed/d' /etc/rc.local                    
fi 
