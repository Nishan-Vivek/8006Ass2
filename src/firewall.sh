#!/usr/bin/env bash

#Symbolic Constants as specified in Linux Firewalls 3rd Edition.

IPT="/sbin/iptables"
#EXTERNAL_INTERFACE="enp0s3"
#LOOPBACK_INTERFACE="lo"
#LOOPBACK_IP="127.0.0.1"
#PRIVPORTS="0:1023"
UNPRIVPORTS="1024:65535"
#BROADCAST_SRC="0.0.0.0"
#BROADCAST_DEST="255.255.255.255"
GATEWAY="192.168.5.1"
#NAMESERVER="192.168.1.1"
#DHCP_SERVER="192.168.1.1"
#SSH_PORTS="1024:65535"

#Stuff for forwarding firewall
LAN_INTERFACE="enp0s8"
LAN_ADDRESSES="192.168.5.0/24"
EXTERNAL_INTERFACE="enp0s3"

sysctl -w net.ipv4.ip_forward=1

#Remove  any  existing  rules  from  all  chains
$IPT --flush
$IPT -t nat --flush
$IPT -t mangle --flush

#Delete any user-defined chains
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

#  Reset  the  default  policy
$IPT --policy INPUT ACCEPT
$IPT --policy OUTPUT ACCEPT
$IPT --policy FORWARD ACCEPT
$IPT -t nat --policy PREROUTING ACCEPT
$IPT -t nat --policy OUTPUT ACCEPT
$IPT -t nat --policy POSTROUTING ACCEPT
$IPT -t mangle --policy PREROUTING ACCEPT
$IPT -t mangle --policy OUTPUT ACCEPT

# Parameter to allow script to stop the firewall
if [ "$1" = "stop" ]
 then
    echo "Firewall completely stopped! WARNING: THIS HOST HAS NO FIREWALL RUNNING."
    exit 0
fi


$IPT -A FORWARD -i $LAN_INTERFACE -o $EXTERNAL_INTERFACE -p tcp -s $LAN_ADDRESSES --sport $UNPRIVPORTS -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT

$IPT -A INPUT -i $LAN_INTERFACE -p tcp -s $LAN_ADDRESSES --sport $UNPRIVPORTS -d $GATEWAY -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -o $LAN_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT