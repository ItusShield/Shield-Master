#!/bin/sh

#################################################################################
# update.sh									#
# created By: Hans / Roadrunnere42						#
# Modified: 13th Augest 2017							#
# called by: /etc/init.d/dnsmasq						#
# Purpose: To retreive blockdomain ip and blacklist ip, compare and if changed	#
# update all rules with new ip. Go through the selected web filter rules and	#
# the only ones ticked will be copied to /tmp/ramdisk/itus.dns.txt, whitelist	#
# will be checked for blanks lines, whitespaces, www, quotation marks before	#
# being removed from /tmp/ramdisk/itus.dns.txt.					#
# blacklist will be checked for blanks lines, whitespaces, www, quotation marks	#
# before being removed from /tmp/ramdisk/itus.dns.txt				#
# /tmp/ramdisk/itus.dns.txt is sorted and duplicate filters will be deleted	#
# then saved to /etc/ITUS_DNS.txt						#
# Replaces /etc/itus/update_blacklist.sh					#
# Replaces /etc/itus/write-categories.sh					#
# Replaces /etc/itus/lists/whitelist.sh /etc/itus/lists/white.list		#
# Replaces /etc/itus/lists/blacklist.sh /etc/itus/lists/black.list		#
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
		cp   /etc/itus/lists/$list /tmp/ramdisk/$list
		fi
	echo /tmp/ramdisk/$list  # added as display point for checking only
	sed -i -E "s/\/[0-9]+.[0-9]+.[0-9]+.[0-9]+$|\/$/\/$blockdomain_ip/g" /tmp/ramdisk/$list &
	done
	# Wait for the last process to complete before exiting
	wait

############################################################################################################################
# Run through rule list and copy back to /etc/itus/lists/$list	                                                           #
############################################################################################################################
echo " Building black list..."
for list in ${blacklist}
	do
	mv /tmp/ramdisk/$list /etc/itus/lists/$list
	done
	echo "finished"
	logger -s "update_blacklist" -t "Updated redirect ip address: $blockdomain_ip"
fi

############################################################################################################################
# Purpose: To go through the selected web filter rules and the only ones ticked will be copied.                            #
############################################################################################################################
# Clear file
touch  /etc/ITUS_DNS.txt

##########################################################################################
# Check to see if there is a mount point in /tmp/ramdisk.
# This is used the first time you run this script on the Shield to created the mount point.
##########################################################################################
if [ ! -d "/tmp/ramdisk" ] ; then
	mkdir /tmp/ramdisk
fi

##########################################################################################
# checks which rules are ticked from gui then copies to ramdisk.
##########################################################################################

for filter in $(grep content_ /etc/config/e2guardian | grep \'1\' | cut -d "_" -f 2 | cut -d ' ' -f 1)
	do
	cat /etc/itus/lists/$filter >> /tmp/ramdisk/ITUS_DNS.tmp
	done

#################################################################################################
# Check to see if ITUS_DNS,tmp is blank or missing. The file can be empty   but must		#
# be present or error will happen.								#
#################################################################################################
if [ ! -f "/tmp/ramdisk/ITUS_DNS.tmp" ]  ;  then
	echo " /tmp/ramdisk/ITUS_DNS.tmp file not found so creating blank file."
	touch "/tmp/ramdisk/ITUS_DNS.tmp"
fi

##########################################################################################
# removes blanks lines, whitespaces at begining,end and www. at begin if present
# removes duplicated entres, saved to /tmp/ramdisk/ITUS_DNS.tmp
##########################################################################################

WHITELIST="/etc/itus/lists/white.list"
# Remove blank lines
sed -i '/^$/d' $WHITELIST

# Remove whirespaces at begin of line
sed -i 's/^ *//' $WHITELIST

# Remove www. at begin of line
sed -i 's/^www.*//' $WHITELIST

filenamewhite="/etc/itus/lists/white.list"
cat $filenamewhite | while read -r line || [[ -n "$line" ]]; do
	sed -i '/'$line'/d' /tmp/ramdisk/ITUS_DNS.tmp
done
echo "whitelist done"

#########################################################################################
# removes blanks lines, whitespaces at begining,end , www. and quotation marks
# removes duplicated entres saved to /tmp/ramdisk/ITUS_DNS.tmp
#########################################################################################

BLACKLIST="/etc/itus/lists/black.list"

# Remove blank lines
sed -i '/^$/d' $BLACKLIST

# Remove whirespaces at begin of line
sed -i 's/^ *//' $BLACKLIST

# Remove www. at begin of line
sed -i 's/^www.*//' $BLACKLIST

# Remove quotation marks
sed -i 's/"//g' $BLACKLIST

ip=$(uci get network.blockdomain.ipaddr)
filenameblack="/etc/itus/lists/black.list"
cat $filenameblack | while read -r line || [[ -n "$line" ]]; do
	ADDRESS="/${line}/${ip}"
	echo "address=${ADDRESS}" >> /tmp/ramdisk/ITUS_DNS.tmp
done
echo "blacklist done"

##########################################################################################
# sorting temp file and removing any duplicated then saving to /etc/ITUS_DNS.txt
# remove tmp files /tmp/ramdisk/ITUS_DNS.tmp
##########################################################################################

echo "sorting itus.dns file and deleting duplicates"
sort -u /tmp/ramdisk/ITUS_DNS.tmp >/etc/ITUS_DNS.txt
rm /tmp/ramdisk/ITUS_DNS.tmp
echo "finished"
