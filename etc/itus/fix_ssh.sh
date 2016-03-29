rm /etc/dropbear/dropbear*
sleep 3
dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
sleep 3
dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key
#sleep 3
#/etc/init.d/dropbear start
#sleep 3
#/etc/init.d/firewall restart

