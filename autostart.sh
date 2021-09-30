#!/bin/sh
#
# chkconfig: 345 20 80
# description: This script takes care of starting \
#

userid1=$(id -u Super1)
userid2=$(id -u Super2)
echo "userid1:"${userid1}
echo "userid2:"${userid2}
ipAdd1="$(curl -s 169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)"
ipAdd2="$(curl -s 169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address)"
echo "ipAdd1:"${ipAdd1}
echo "ipAdd2:"${ipAdd2}
if [ ! -d "/var/run/ss5/" ];then
mkdir /var/run/ss5/
echo "create ss5 success!"
else
echo "/ss5/ is OK!"
fi
ss5 -u Super1 -b ${ipAdd1}
ss5 -u Super2 -b ${ipAdd2}

iptables -t mangle -A OUTPUT -m owner --uid-owner ${userid1} -j MARK --set-mark ${userid1}
iptables -t nat -A POSTROUTING -m mark --mark ${userid1} -j SNAT --to-source ${ipAdd1}

iptables -t mangle -A OUTPUT -m owner --uid-owner ${userid2} -j MARK --set-mark ${userid2}
iptables -t nat -A POSTROUTING -m mark --mark ${userid2} -j SNAT --to-source ${ipAdd2}
