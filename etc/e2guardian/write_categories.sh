#!/bin/sh

# TODO: write categories

sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/phishing\/urls>/d' /etc/e2guardian/lists/bannedurllist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/spyware\/urls>/d' /etc/e2guardian/lists/bannedurllist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/ads\/urls>/d' /etc/e2guardian/lists/bannedurllist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/drugs\/urls>/d' /etc/e2guardian/lists/bannedurllist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/porn\/urls>/d' /etc/e2guardian/lists/bannedurllist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/sexuality\/urls>/d' /etc/e2guardian/lists/bannedurllist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/weapons\/urls>/d' /etc/e2guardian/lists/bannedurllist

sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/ads\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/blasphemy\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/drugs\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/gambling\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/malicious\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/phishing\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/piracy\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/porn\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/proxies\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/racism\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/sexuality\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/spyware\/domains>/d' /etc/e2guardian/lists/bannedsitelist
sed -i '/.Include<\/etc\/e2guardian\/lists\/blacklists\/weapons\/domains>/d' /etc/e2guardian/lists/bannedsitelist


FILTERS=`grep content_ /etc/config/e2guardian | grep \'1\' | cut -d ' ' -f 2 | cut -d "_" -f 2`

for filter in $FILTERS
do
	echo ".Include</etc/e2guardian/lists/blacklists/$filter/urls>" >> /etc/e2guardian/lists/bannedurllist
	echo ".Include</etc/e2guardian/lists/blacklists/$filter/domains>" >> /etc/e2guardian/lists/bannedsitelist
done
