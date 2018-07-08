#!/bin/sh
# used to upgrade packages and snort package

echo "installing packages"
sleep 2
echo "installing openssl update"
sleep 4
opkg install ./openssl-util_1.0.2o-1_mips64_octeon.ipk
echo "installing new theme material"
sleep 4
opkg install ./luci-theme-material_0.2.17-1_all.ipk
echo "moved files"
sleep 1

sleep 4
echo "Backing up daq file"
cp /usr/lib/daq/daq_nfq.so /tmp/daq_nfq.so
sleep 2

opkg install ./libdaq_2.0.6-1_octeon.ipk
echo "installing libdaq"
sleep 4
opkg install ./libpcre_8.41-1_octeon.ipk
echo "installing libpcre"
sleep 4
opkg install ./zlib_1.2.11-1_octeon.ipk
echo "installing zlibl"
sleep 4
echo "Backing up snort files"
mv /etc/snort /etc/snort.bak
mv /etc/init.d/snort /etc/init.d/snort.bak
sleep 4

opkg install ./snort_2.9.9.0-2_octeon.ipk
echo "installing snort 2.9.9.0-2"
sleep 4

echo "coping back files"
if [[ -f //tmp/daq_nfq.so ]] ; then cp /tmp/daq_nfq.so /usr/lib/daq/daq_nfq.so  ; else /tmp/backup/daq_nfq.so /usr/lib/daq/daq_nfq.so  ; fi

cp -r /etc/snort.bak/* /etc/snort
cp /etc/init.d/snort.bak /etc/init.d/snort
sleep 4

echo " removing backups"
rm -r /etc/snort.bak
rm /etc/init.d/snort.bak
sleep 4


if [[ ! -d "/usr/lib/snort_dynamicpreprocessor/Disabled" ]] ;
	then
	mkdir /usr/lib/snort_dynamicpreprocessor/Disabled
fi
mv /usr/lib/snort_dynamicpreprocessor/*.*  /usr/lib/snort_dynamicpreprocessor/Disabled 2>/dev/null

echo " moving back snort files for dynamicprepocessor SSL and DNS"

mv /usr/lib/snort_dynamicpreprocessor/Disabled/libsf_ssl_preproc.so.0.0.0 /usr/lib/snort_dynamicpreprocessor/
mv /usr/lib/snort_dynamicpreprocessor/Disabled/libsf_ssl_preproc.so /usr/lib/snort_dynamicpreprocessor/
mv /usr/lib/snort_dynamicpreprocessor/Disabled/libsf_ssl_preproc.so.0 /usr/lib/snort_dynamicpreprocessor/

mv /usr/lib/snort_dynamicpreprocessor/Disabled/libsf_dns_preproc.so.0.0.0 /usr/lib/snort_dynamicpreprocessor/
mv /usr/lib/snort_dynamicpreprocessor/Disabled/libsf_dns_preproc.so /usr/lib/snort_dynamicpreprocessor/
mv /usr/lib/snort_dynamicpreprocessor/Disabled/libsf_dns_preproc.so.0 /usr/lib/snort_dynamicpreprocessor/


echo "moved files"
sleep 5


echo " "
echo " Now going to run fw_upgrade script"
sleep 3
sh /sbin/fw_upgrade
echo ""
echo " Now going to reboot the shield"
echo " Remember it can take upto 2 minutes to reboot and get internet connection again"#
sleep 5
echo " now close this window and wait 2 minutes"
sleep 5
reboot -f
