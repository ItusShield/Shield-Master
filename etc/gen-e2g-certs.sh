
sh /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db
chown -R nobody:nogroup /var/lib/ssl_db
# Generate Private Key
openssl genrsa -out squid.key 2048  
# Create Certificate Signing Request
openssl req -new -key squid.key -out squid.csr  
# Sign Certificate
#openssl x509 -req -days 3652 -in squid.csr -signkey squid.key -out squid.cert -subj "/C=US/ST=CA/L=SJ/O=ITUS/OU=Shield/CN=ITUS.io"

mv squid.key /etc/squid/ssl/
mv squid.csr /etc/squid/ssl/
mv squid.cert /etc/squid/ssl/
