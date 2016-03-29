sed -i 's/^.//' /etc/config/dropbear
/etc/init.d/dropbear start
/etc/init.d/firewall restart
mount /dev/mmcblk0p1 /overlay
cd /overlay
ls -alst
