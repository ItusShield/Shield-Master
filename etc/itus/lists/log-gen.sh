# Called by: web filter log window
#set -x

# Get network id
network_id_regex="inet [0-9]\+\.[0-9]\+\.[0-9]\+\."
network_id=$(ip addr show br-lan | grep -o "${network_id_regex}" | head -1 | cut -d' ' -f2)
blockdomain=`uci get network.blockdomain.ipaddr`
logread | grep $network_id | awk '/query/ { print $1"  "$2"  "$3"  "$5"  "$4"  QUERIED:  "$9"  "$11}' > /tmp/wf-dirty.log
logread | grep $blockdomain | awk '/dnsmasq/ { print $1"  "$2"  "$3"  "$5"  "$4"  STOPPED:  "$9 }' >> /tmp/wf-dirty.log
logread | grep $blockdomain | awk '/dnsmasq/ { print $1"  "$2"  "$3"  "$5"  "$4"  STOPPED:  "$9 }' > /tmp/dns_stopped_tmp.log
sort -r /tmp/dns_stopped_tmp.log > /tmp/dns_stopped.log
rm /dns_stopped_tmp.log
sort -r /tmp/wf-dirty.log > /tmp/dns.log
rm /tmp/wf-dirty.log
