# Clear files
> /etc/ITUS_DNS.txt

FILTERS=`grep content_ /etc/config/e2guardian | grep \'1\' | cut -d "_" -f 2 | cut -d ' ' -f 1`
for filter in $FILTERS
do
#        cat "/etc/itus/lists/$filter" >> /etc/ITUS_DNS.tmp
 	cat "/mnt/ramdisk/$filter" >> /mnt/ramdisk/ITUS_DNS.tmp
done
# cat /etc/ITUS_DNS.tmp | sort | uniq > /etc/ITUS_DNS.txt
# rm /etc/ITUS_DNS.tmp
cat /mnt/ramdisk/ITUS_DNS.tmp | sort | uniq > /etc/ITUS_DNS.txt
rm /mnt/ramdisk/ITUS_DNS.tmp

