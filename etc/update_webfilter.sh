#set -x
# Get br-lan ip address
IP_REGEX="[0-9]\+\.[0-9]\+\.[0-9]\+\."

# Get network id
network_id_regex="inet [0-9]\+\.[0-9]\+\.[0-9]\+\."
network_id=$(ip addr show br-lan | grep -o "${network_id_regex}" | head -1 | cut -d' ' -f2)
slash24="0/24"

# Get ip address
ip_regex="inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"
ip_address=$(ip addr show br-lan | grep -o "${ip_regex}" | head -1 | cut -d' ' -f2)

# Create redirect ip address
let host_id=$(ip addr show br-lan | grep -o "${ip_regex}" | head -1 | cut -d' ' -f2 | cut -d'.' -f4)
let host_id=$host_id+1
ip=$(echo "$network_id$host_id")

empty="uci: Entry not found"

# Get alias network id
blockdomain_network_id=$(uci get network.blockdomain.ipaddr | grep -o "${IP_REGEX}")

# Get block redirect domain ip address
blockdomain_ip=$(uci get network.blockdomain.ipaddr)

# Set up network alias if it has not been setup
check_network=$(uci show network.blockdomain 2>&1)
if [ "$check_network" == "$empty" ]
then
	uci set network.blockdomain=interface
	uci set network.blockdomain.ifname=br-lan
	uci set network.blockdomain.proto=static
	uci set network.blockdomain.ipaddr=$ip
	uci set network.blockdomain.netmask=255.255.255.0
	uci commit
	ifup blockdomain
fi

# Setup firewall redirect if it has not been setup
check_firewall=$(uci show firewall.@redirect[0].name 2>&1)
if [ "$check_firewall" == "$empty" ]
then
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
	uci set firewall.@redirect[-1].src_dip=$network_id$slash24
	uci set firewall.@redirect[-1].src_dport=53
	uci set firewall.@redirect[-1].dest_ip=$ip_address
	uci set firewall.@redirect[-1].dest_port=53
	uci set firewall.@redirect[-1].name='dns-traffic-to-shield'
	uci commit

	# Reload firewall rules
	/etc/init.d/firewall reload
fi

# Update ip addresses if the network id has changed
if [ "$blockdomain_network_id" != "$network_id" ]
then
	# Update network blockdomain
	ifdown blockdomain
	uci set network.blockdomain.ipaddr=$ip
	uci commit
	ifup blockdomain

	# Update firewall source address
	uci set firewall.@redirect[0].src_dip=$ip

	# Update firewall destination address
	uci set firewall.@redirect[0].dest_ip=$ip

	# Update dns redirect rule to ensure all
	# dns request are routed to the Shield
	uci set firewall.@redirect[1].dest_ip=$ip_address

	# Commit changes
	uci commit
	/etc/init.d/firewall reload
	/etc/init.d/odhcpd restart

fi

# setup http server that will server the itus logo
check_http=$(uci show uhttpd.Itusfilter 2>&1)
if [ "$check_http" == "$empty" ] 
then
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
	/etc/init.d/uhttpd restart
fi

# Restart services
/etc/init.d/dnsmasq restart
