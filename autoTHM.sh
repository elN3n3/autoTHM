#!/bin/bash

# *** Auto THM VPN connection + Firewall Setup for THM rooms ***
# by: elNene using Wh1teDrvg0n's "Safe-THM" iptables script.

# Functions:
function ctrl_c(){
        echo -e "\n\n[!] Leaving ...\n"
        iptables -F
        iptables -X
        iptables -Z
        exit 1
}

function helpPanel(){
        echo -e "\n*** AutoTHM Help Panel ***"
        echo -e "\n[!] PLEASE: Run this command as sudo, otherwise it won't work!"
        echo -e "\n[!] Use: \"$ sudo ./autoTHM.sh\""
}

function safeVPN(){

  echo -n -e "\n[?] Please type the target IP (x.x.x.x) -> " && read i

  # IPv4 flush
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  iptables -t nat -F
  iptables -t mangle -F
  iptables -F
  iptables -X
  iptables -Z

  # IPv6 flush
  ip6tables -P INPUT DROP
  ip6tables -P FORWARD DROP
  ip6tables -P OUTPUT DROP
  ip6tables -t nat -F
  ip6tables -t mangle -F
  ip6tables -F
  ip6tables -X
  ip6tables -Z

  # Ping machine
  iptables -A INPUT -p icmp -i tun0 -s $i --icmp-type echo-request -j ACCEPT
  iptables -A INPUT -p icmp -i tun0 -s $i --icmp-type echo-reply -j ACCEPT
  iptables -A INPUT -p icmp -i tun0 --icmp-type echo-request -j DROP
  iptables -A INPUT -p icmp -i tun0 --icmp-type echo-reply -j DROP
  iptables -A OUTPUT -p icmp -o tun0 -d $i --icmp-type echo-reply -j ACCEPT
  iptables -A OUTPUT -p icmp -o tun0 -d $i --icmp-type echo-request -j ACCEPT
  iptables -A OUTPUT -p icmp -o tun0 --icmp-type echo-request -j DROP
  iptables -A OUTPUT -p icmp -o tun0 --icmp-type echo-reply -j DROP

  # Allow VPN connection only from machine
  iptables -A INPUT -i tun0 -p tcp -s $i -j ACCEPT
  iptables -A OUTPUT -o tun0 -p tcp -d $i -j ACCEPT
  iptables -A INPUT -i tun0 -p udp -s $i -j ACCEPT
  iptables -A OUTPUT -o tun0 -p udp -d $i -j ACCEPT
  iptables -A INPUT -i tun0 -j DROP
  iptables -A OUTPUT -o tun0 -j DROP
}

function connectVPN(){

        #echo -n -e "\n[?] Almost there, now type the name of your vpn file (file.ovpn) -> " && read vpn_file
        openvpn --config $vpn_file

}

# *** Script body: ***

counter="0"
trap ctrl_c INT

while getopts "h" arg; do
        case $arg in
                h) let counter+=1;;
        esac
done

if [ "$counter" -eq "0" ]; then
        safeVPN && connectVPN
else
        helpPanel
fi
