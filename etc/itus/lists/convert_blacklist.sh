#list="ads blasphemy dating drugs gambling illegal malicious piracy porn proxies racism social"
#for i in $list
#do
#	cp $i temp
#	cat temp | awk '{print "address=/"$2"/"$1}' > $i
#done
#:rm temp
