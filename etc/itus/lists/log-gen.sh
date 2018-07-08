#################################################################################################
# Version 2											#
# Modified by - Roadrunnere42									#
# Modified: 13 August 2017									#
# Purpose: Generate logs with blocked domains and changed the format to be more readable.	#
# Called by: web filter log window								#
#################################################################################################

network_id_regex="inet [0-9]\+\.[0-9]\+\.[0-9]\+\."
network_id=$(ip addr show br-lan | grep -o "${network_id_regex}" | head -1 | cut -d' ' -f2)
blockdomain=`uci get network.blockdomain.ipaddr`
logread | grep $network_id | awk '/query/ { print $1"  "$2"  "$3"  "$5"  "$4"  QUERIED:  "$9"  "$11}' | sort -r > /tmp/dns.log
logread | grep $blockdomain | awk '/dnsmasq/ { print $1"  "$2"  "$3"  "$5"  "$4"  STOPPED:  "$9 }'  | sort -r > /tmp/dns_stopped.log
