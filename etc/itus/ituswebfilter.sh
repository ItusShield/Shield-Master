#!/bin/sh

#set -x

# Regular expressiosn for ip addresses
PRIVATE_ADDRESS="^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)"
NET_ID_REGEX="[0-9]\+\.[0-9]\+\.[0-9]\+\."
IP_REGEX="[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"
SLASH24="0/24"

# Get ip address
ip_address=$(ip addr show br-lan | grep -o "inet ${IP_REGEX}" | head -1 | cut -d' ' -f2)

# Exit if ip_address or blockdomain_ip is empty or 0.0.0.0
if [ ! `echo $ip_address | grep -E $PRIVATE_ADDRESS` ]
then
	
	logger -t "update_webfilter" -s "ip address is invalid: $ip_address"
	exit
fi

# Create secondary ip address for br-lan
network_id=$(echo $ip_address | grep -o "${NET_ID_REGEX}")
let host_id=$(echo $ip_address | cut -d'.' -f4)
let host_id=$host_id+1
ip=$(echo "$network_id$host_id")

create_blockdomain()
{
	uci set network.blockdomain=interface
	uci set network.blockdomain.ifname=br-lan
	uci set network.blockdomain.proto=static
	uci set network.blockdomain.ipaddr=$ip
	uci set network.blockdomain.netmask=255.255.255.0
	uci commit
	ifup blockdomain
}

destroy_blockdomain()
{
	uci delete network.blockdomain
	uci commit
}

create_fw_redirects()
{
	# Redirect all blocked domains to x.x.x.x:88
	uci add firewall redirect
	uci set firewall.@redirect[-1].target=DNAT
	uci set firewall.@redirect[-1].src=lan
	uci set firewall.@redirect[-1].proto=tcp
	uci set firewall.@redirect[-1].src_dip=$ip
	uci set firewall.@redirect[-1].src_dport=80
	uci set firewall.@redirect[-1].dest_ip=$ip
	uci set firewall.@redirect[-1].dest_port=88
	uci set firewall.@redirect[-1].name=Itusfilter
	uci commit

	# Redirect all dns traffic to Shield
	uci add firewall redirect
	uci set firewall.@redirect[-1].target=DNAT
	uci set firewall.@redirect[-1].src=lan
	uci set firewall.@redirect[-1].proto=tcpudp
	uci set firewall.@redirect[-1].src_dip=any
	uci set firewall.@redirect[-1].src_dport=53
	uci set firewall.@redirect[-1].dest_ip=$ip_address
	uci set firewall.@redirect[-1].dest_port=53
	uci set firewall.@redirect[-1].name='dns-traffic-to-shield'
	uci commit
}

destroy_fw_redirects()
{
	let index=0
	while [ $(uci get firewall.@redirect[$index].name) != "uci: Entry not found" ]
	do
		redirect_name=`uci get firewall.@redirect[$index].name`
		if [ "$redirect_name" == "Itusfilter" ] || [ "$redirect_name" == "dns-traffic-to-shield" ]
		then
			uci delete firewall.@redirect[$index]
		else
			let index=$index+1
		fi 
	done
}

create_http_server()
{
	uci add uhttpd uhttpd
	uci rename uhttpd.@uhttpd[-1]=Itusfilter
	uci add_list uhttpd.@uhttpd[-1].listen_http=0.0.0.0:88
	uci set uhttpd.@uhttpd[-1].home=/www/block/
	uci set uhttpd.@uhttpd[-1].rfc1918_filter=1
	uci set uhttpd.@uhttpd[-1].error_page=/itus_error_8.png
	uci set uhttpd.@uhttpd[-1].index_page=index.html
	uci set uhttpd.@uhttpd[-1].max_requests=3
	uci set uhttpd.@uhttpd[-1].max_connections=100
	uci set uhttpd.@uhttpd[-1].network_timeout=300
	uci set uhttpd.@uhttpd[-1].http_keepalive=20
	uci set uhttpd.@uhttpd[-1].tcp_keepalive=1
	uci set uhttpd.@uhttpd[-1].ubus_prefix=/ubus
	uci commit
}

destroy_http_server()
{
	uci delete uhttpd.Itusfilter
}

if [ "$1" == "create" ]
then
	Add blacklist to dnsmasq
	echo "conf-file=/etc/ITUS_DNS.txt" >> /etc/dnsmasq.conf

	# Create blockdomain and firewall redirect rules
	create_blockdomain
	create_fw_redirects
	create_http_server

	# Reload services
	/etc/init.d/firewall reload
	/etc/init.d/uhttpd restart
	/etc/init.d/dnsmasq restart

	# Log created interface and firewall redirect rules
	logger -t "update_webfilter" -s "Added blacklist to dnsmasq"
	logger -t "update_webfilter" -s "created network.interface.blockdomain: $ip"
	logger -t "update_webfilter" -s "created firewall.@redirect[0].Itusfilter: $ip"
	logger -t "update_webfilter" -s "created firewall.@redirect[1]dns-traffic-to-shield: $ip"
	logger -t "update_webfilter" -s "created uhttpd.Itusfilter"
fi

if [ "$1" == "update" ]
then
	# Remove blacklist from dnsmasq
	sed -i '/conf-file=\/etc\/ITUS_DNS.txt/d' /etc/dnsmasq.conf

	# Destroy blockdomain interface and firewall redirect rules
	destroy_blockdomain
	destroy_fw_redirects
	destroy_http_server

	Add blacklist to dnsmasq
	echo "conf-file=/etc/ITUS_DNS.txt" >> /etc/dnsmasq.conf

	# Create blockdomain interface and firewall redirect rules
	create_blockdomain
	create_fw_redirects
	create_http_server

	# Reload services
	/etc/init.d/firewall reload
	/etc/init.d/uhttpd restart
	/etc/init.d/dnsmasq restart

	# Log updates
	logger -t "update_webfilter" -s "updated dnsmasq blacklist"
	logger -t "update_webfilter" -s "updated network.interface.blockdomain: $ip"
	logger -t "update_webfilter" -s "updated firewall.@redirect[0].Itusfilter: $ip"
	logger -t "update_webfilter" -s "updated firewall.@redirect[1]dns-traffic-to-shield: $ip"
	logger -t "update_webfilter" -s "updated uhttpd.Itusfilter"
fi

if [ "$1" == "destroy" ]
then
	# Remove blacklist from dnsmasq
	sed -i '/conf-file=\/etc\/ITUS_DNS.txt/d' /etc/dnsmasq.conf

	# Destroy web filter
	destroy_blockdomain
	destroy_fw_redirects
	destroy_http_server

	# Reload services
	/etc/init.d/firewall reload
	/etc/init.d/uhttpd restart
	/etc/init.d/dnsmasq restart

	# Log updates
	logger -t "update_webfilter" -s "removed ITUS_DNS.txt from /etc/dnsmasq.conf"
	logger -t "update_webfilter" -s "destroyed network.interface.blockdomain"
	logger -t "update_webfilter" -s "destroyed firewall.@redirect[0].Itusfilter"
	logger -t "update_webfilter" -s "destroyed firewall.@redirect[1].dns-traffic-to-shield"
	logger -t "update_webfilter" -s "destroyed uhttpd.Itusfilter"
fi	
