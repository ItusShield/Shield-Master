#########################################################################################
# update_blacklist.sh									#
# By: ITUS										#
# version 3										#
# Modified: 14th August 2017								#
# called by: /etc/init.d/dnsmasq							#
# Purpose: To go through the selected web filter rules and the only ones ticked will	#
# be copied, sorted and duplicate one deleted, then copied to /etc/ITUS_DNS.txt.	#
# changes: roadrunnere42 made typo adjustments and change way web contents are selected	#
# changes: roadrunnere42 Added checks for ramdisk, error checking for missing 		#
# 		or blank files, added comments.						#
# changes: Hans added ram disk feature, orginal code left in.				#
#########################################################################################

# Clear file
> /etc/ITUS_DNS.txt

#################################################################################################
# Check to see if there is a mount point in /tmp/ramdisk.					#
# This is used the first time you run this script on the Shield to created the mount point.	#
#################################################################################################

	if [ ! -d "/tmp/ramdisk" ] ; then
	mkdir /tmp/ramdisk
	fi

#################################################################################################
# Checks which rules are ticked from gui then copies to ramdisk.				#
#################################################################################################

for filter in $(grep content_ /etc/config/e2guardian | grep \'1\' | cut -d "_" -f 2 | cut -d ' ' -f 1)
	do
	cat /etc/itus/lists/$filter >> /tmp/ramdisk/ITUS_DNS.tmp
	done

#################################################################################################
# Check to see if ITUS_DNS,tmp is blank or missing and if yes skip. The file can be empty	#
# if no rules are ticked in the gui causing error to happen, also it Sorts rules in		#
# memory, deletes duplicate ones, then copies back to /etc/ITUS_DNS.txt				#
#################################################################################################

if [ ! -f "/tmp/ramdisk/ITUS_DNS.tmp" ]  ;  then
	echo " /tmp/ramdisk/ITUS_DNS.tmp file not found so creating blank file."
	touch "/tmp/ramdisk/ITUS_DNS.tmp"
fi

if [ -s "/tmp/ramdisk/ITUS_DNS.tmp" ]  ;  then
	echo " copying new sorted rules....this may take a minute."
	cat /tmp/ramdisk/ITUS_DNS.tmp | sort | uniq > /etc/ITUS_DNS.txt
	rm /tmp/ramdisk/ITUS_DNS.tmp
else
	echo "File appears to be empty usually because no web filter rules selected in gui"
fi
