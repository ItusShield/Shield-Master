#set -x

# Get network id
network_id_regex="inet [0-9]\+\.[0-9]\+\.[0-9]\+\."
network_id=$(ip addr show br-lan | grep -o "${network_id_regex}" | head -1 | cut -d' ' -f2)

logread | grep $network_id | grep query > /tmp/wf-dirty.log

sed '1!G;h$!d' /tmp/wf-dirty.log > /tmp/dns.log
