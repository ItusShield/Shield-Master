#!/bin/sh
#set +x
# Get block redirect domain ip address
ip_regex="[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"
blockdomain_ip=$(uci get network.blockdomain.ipaddr)
blacklist_ip=`head -1 /etc/itus/lists/ads | cut -d'/' -f3`

if [[ `echo $blockdomain_ip | grep -o $ip_regex` && `echo $blacklist_ip | grep -o $ip_regex` && "$blockdomain_ip" != "$blacklist_ip" ]]
then
        #Process blacklist in parallel to increase performance
#       blacklist=`echo "porn drugs gambling proxies dating blasphemy racism malicious piracy social ads illegal"`

        blacklist=`grep content_ /etc/config/e2guardian | grep \'1\' | cut -d "_" -f 2 | cut -d ' ' -f 1`
        for list in ${blacklist}
        do
                # sed -i -E "s/\/[0-9]+.[0-9]+.[0-9]+.[0-9]+$|\/$/\/$blockdomain_ip/g" /etc/itus/lists/$list &
		sed -i -E "s/\/[0-9]+.[0-9]+.[0-9]+.[0-9]+$|\/$/\/$blockdomain_ip/g" /mnt/ramdisk/$list &

        done

        # Wait for the last process to complete before exiting
        wait
        logger -s "update_blacklist" -t "Updated redirect ip address: $blockdomain_ip" 
fi
