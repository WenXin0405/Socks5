#!/bin/sh
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
ss5 "-u Super1 -b "${ipAdd1}
ss5 "-u Super2 -b "${ipAdd2}
