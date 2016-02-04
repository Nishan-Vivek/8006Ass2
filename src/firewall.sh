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
LAN_ADDRESS="192.168.5.0/24"
LAN_TARGETIP="192.168.5.2"
EXTERNAL_INTERFACE="enp0s3"



#Ensure kernel allows forwarding
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

#Set default to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#User Defined Chains
iptables -N ICMPin
iptables -N ICMPout
iptables -N TCPin
iptables -N TCPout
iptables -N UDPin
iptables -N UDPout

#Setup NAT/Masquerade/SNAT for outgoing packets
iptables -t nat -A POSTROUTING -o $EXTERNAL_INTERFACE -j MASQUERADE

#Setup DNAT for portfowarding so services can be reached behind firewall.
iptables -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -j DNAT --to-destination $LAN_TARGETIP

#Accept fragments.


#Forward packets to user defined chains
iptables -A FORWARD -p icmp -j ICMPin
iptables -A FORWARD -p icmp -j ICMPout
iptables -A FORWARD -p tcp -j TCPin
iptables -A FORWARD -p tcp -j TCPout
iptables -A FORWARD -p udp -j UDPin
iptables -A FORWARD -p udp -j UDPout

#Accept fragments
iptables -A FORWARD -f -j ACCEPT



#Explicit Drops
#Do  not  accept  any  packets  with  a  source  address  from  the  outside  matching  your internal network.
iptables -A TCPin -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -s $LAN_ADDRESS -j DROP
iptables -A UDPin -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -s $LAN_ADDRESS -j DROP
iptables -A ICMPin -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -s $LAN_ADDRESS -j DROP
#You must ensure the you reject those connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).
iptables -A TCPin -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -p tcp --syn  --dport $UNPRIVPORTS -j DROP
#Drop all TCP packets with the SYN and FIN bit set.
iptables -A TCPin -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
#Do not allow Telnet packets at all.
iptables -A TCPin -p tcp --dport 23 -j DROP
iptables -A TCPin -p tcp --sport 23 -j DROP
iptables -A TCPout -p tcp --dport 23 -j DROP
iptables -A TCPout -p tcp --dport 23 -j DROP



#iptables -A FORWARD -i $EXTERNAL_INTERFACE -o $LAN_INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -i $LAN_INTERFACE -o $EXTERNAL_INTERFACE -j ACCEPT
#iptables -t nat -A POSTROUTING -o $EXTERNAL_INTERFACE -j MASQUERADE


#For FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput".
iptables -A PREROUTING -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
iptables -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
iptables -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput

#Drop all packets destined for the firewall host from the outside.