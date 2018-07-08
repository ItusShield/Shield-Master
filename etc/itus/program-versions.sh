#################################################################################################
# version 2											#
# Created by Roadrunnere42 									#
# Modified : 13th August 2017									#
# Purpose: To get version of programs and save to program-version.log				#
# Checks both Openwrt and Lede Project web sites						#
# This requires the following files to be changed or added					#
# /etc/itus/program-versions.sh		added							#
# /etc/itus/program-version.log		added							#
# /usr/lib/lua/luci/mode/cbi/itus.lua	changed							#
# /etc/opkg.conf			changed							#
#################################################################################################

touch /etc/itus/program-versions.log
echo > /etc/itus/program-versions.log
echo "The two websites seem to update the programs at different times, hence why it checks both websites.These website are check during Shield's nightly updates." >> /etc/itus/program-versions.log
echo "Always install the latest version from which ever website has the latest version." >> /etc/itus/program-versions.log
echo \ >> /etc/itus/program-versions.log
# runs the program opkg info with whats in the loop and gets the version number
for i in openssl-util
do
  version=$(opkg info ${i} | grep -i "Version: " | cut -d" " -f2)
  # if a programs is checked but not installed on the Shield then skip
  if [ "${version}" == "" ] ; then
     continue
  fi
echo "Version on the Shield of "${i} "is "${version}   >> /etc/itus/program-versions.log

# retrieves new listing from openwrt snapshots and strippes out junk from file just leaving file names
wget --no-check-certificate https://downloads.openwrt.org/snapshots/trunk/octeon/generic/packages/base/ -O /tmp/index.html 2>/dev/null
cat  /tmp/index.html > /tmp/file
#cat  /tmp/index.html | grep "<tr><td><a href=" | cut -c18- | cut -d"\"" -f1 > /tmp/file
# create loop, place programs that you want to check after openssl-util, more programs can be checked for

   echo \ >> /etc/itus/program-versions.log
   echo "********OPENWRT WEBSITE********" >> /etc/itus/program-versions.log
   version2=$(cat /tmp/file | grep ${i} | cut -d'_' -f2)
   echo  "Version avaliable from OPENWRT website is" ${version2} >> /etc/itus/program-versions.log
   echo \ >> /etc/itus/program-versions.log
   echo "Open WRT download page at https://downloads.openwrt.org/snapshots/trunk/octeon/generic/packages/base/" >> /etc/itus/program-versions.log
   echo \ >> /etc/itus/program-versions.log
done

echo "********LEDE PROJECT WEBSITE********" >> /etc/itus/program-versions.log
# retrieves new listing from openwrt snapshots and strippes out junk from file just leaving file names
wget --no-check-certificate https://downloads.lede-project.org/releases/packages-17.01/mips64_octeon/base/ -O /tmp/index.html 2>/dev/null
cat /tmp/index.html | grep "<tr><td class=\"n\"><a href=" | cut -c30- | cut -d"\"" -f1  > /tmp/file
# create loop, place programs that you want to check after openssl-util, more programs can be checked for
for i in openssl-util
do
# runs the program opkg info with whats in the loop and gets the version number
  version=$(opkg info ${i} | grep -i "Version: " | cut -d" " -f2)
# if a programs is checked but not installed on the Shield then skip
  version2=$(cat /tmp/file | grep ${i} | cut -d'_' -f2)
  echo  "Version avaliable from LEDE website is" ${version2} >> /etc/itus/program-versions.log
  echo \ >> /etc/itus/program-versions.log
  echo "LEDE Project download page at https://downloads.lede-project.org/releases/packages-17.01/mips64_octeon/base/" >> /etc/itus/program-versions.log
  echo \ >> /etc/itus/program-versions.log

done
