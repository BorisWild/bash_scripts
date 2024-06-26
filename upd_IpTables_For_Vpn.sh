#!/bin/bash

IP_REGEX='[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
NETWORK_REGEX="$IP_REGEX\/[0-9]+"

target_gateway=$(ip r | grep default | sed -E "s/^.*via[[:space:]]($IP_REGEX).*$/\1/")
target_interface=$(ip r | grep default | sed -E 's/^.*dev[[:space:]]([^[:space:]]+).*$/\1/')
target_network=$(ip r | grep "$target_interface" | grep 'src' | grep -v 'default' | sed -E "s/^($NETWORK_REGEX).*$/\1/")
target_ip=$(ip r | grep "$target_interface" | grep 'src' | grep -v 'default' | sed -E "s/^.*src[[:space:]]($IP_REGEX).*$/\1/")

echo "gateway:"
echo $target_gateway
echo "interface:"
echo $target_interface
echo "network:"
echo $target_network
echo "ip:"
echo $target_ip


echo "change ip tables? y/n"
read answer
if [ $answer == "n" ]; then
#echo "Start up script"
#sudo openvpn3 sessions-list
#touch www.txt
fi

echo "Making sh file for changing ip tables... changeIpTables.sh"

cat > changeIpTables.sh << ENDFILE
#!/bin/bash
/sbin/ip rule add table 128 from $target_ip
/sbin/ip route add table 128 to $target_network dev $target_interface
/sbin/ip route add table 128 default via $target_gateway
exit 0
ENDFILE

exit 0
