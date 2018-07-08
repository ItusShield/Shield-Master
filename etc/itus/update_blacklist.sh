#!/bin/sh
#################################################################################
# update_blacklist.sh								#
# created By: Hans								#
# Modified: 14th March 2016							#
# called by: /etc/init.d/dnsmasq						#
# Purpose: To retreive blockdomain ip and blacklist ip, compare and if changed	#
# update all rules with new ip.							#
# changes:roadrunnere42 Added checks for ramdisk, error checking for missing 	#
# or blank files, corrected loading errors, added comments.			#
# changes: Hans created								#
#################################################################################

############################################################################################################################
# Gets the blockdomain ip from uci and assigns to blockdomain. added echo $blockdomain_ip just to check # That they is an ip 
############################################################################################################################
ip_regex="[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"
blockdomain_ip=$(uci get network.blockdomain.ipaddr)
echo $blockdomain_ip " this is the blocked domains ip"  # added as display point for checking only

############################################################################################################################
# Check to see if the file ads is present and not empty
############################################################################################################################

	if [[ -f "/etc/itus/lists/ads" && -s "/etc/itus/lists/ads" ]]
		then
# Get the ip address from the first entry in the ads list, added echo $blacklist_ip just to display ip
		blacklist_ip=`head -1 /etc/itus/lists/ads | cut -d'/' -f3`
		echo $blacklist_ip " this is the blacklist ip" # added as display point for checking only
	else
		echo "Error file appears to be missing or empty"
		exit
	fi

############################################################################################################################
# check if blockdomain_ip and blacklist_ip and blockdomain_ip is nor equal to blacklist_ip
# think this is used when the ip of the blocked domain changes and all the rules have to
# be updated with new ip
############################################################################################################################

if [[ `echo $blockdomain_ip | grep -o $ip_regex` && `echo $blacklist_ip | grep -o $ip_regex` && "$blockdomain_ip" != "$blacklist_ip" ]]
then    

# Process blacklist in parallel to increase performance
# blacklist=`echo "porn drugs gambling proxies dating blasphemy racism malicious piracy social ads illegal"`
# blacklist is now pulled from /etc/config/e2gaurdian so allowing only the ones that are select to be downloads.
# & at end of list alowing process to run in background

	blacklist=`grep content_ /etc/config/e2guardian | grep \'1\' | cut -d "_" -f 2 | cut -d ' ' -f 1`
	for list in ${blacklist}
	 do
		if [ ! -d "/mnt/ramdisk/$list " ] ; then # check if the rule folder is in ramdisk,if not copy over.
		cp   /etc/itus/lists/$list /mnt/ramdisk/$list      	
		fi
		            
		# sed -i -E "s/\/[0-9]+.[0-9]+.[0-9]+.[0-9]+$|\/$/\/$blockdomain_ip/g" /etc/itus/lists/$list &
		echo /mnt/ramdisk/$list  # added as display point for checking only
		sed -i -E "s/\/[0-9]+.[0-9]+.[0-9]+.[0-9]+$|\/$/\/$blockdomain_ip/g" /mnt/ramdisk/$list &

	done

	# Wait for the last process to complete before exiting
	wait

#########################################################################################################################
# Run through rule list and copy back to /etc/itus/lists/$list								#
#########################################################################################################################

	for list in ${blacklist}
	do
		mv /mnt/ramdisk/$list /etc/itus/lists/$list
	done

echo "finished"
	logger -s "update_blacklist" -t "Updated redirect ip address: $blockdomain_ip" 
fi
