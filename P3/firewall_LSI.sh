#!/bin/bash

#BORRAR IPTABLES ANTERIORES
/sbin/iptables -F
/sbin/iptables -X
/sbin/iptables -t nat -F

#DROPEAMOS TODO
/sbin/iptables -P INPUT DROP
/sbin/iptables -P OUTPUT DROP
/sbin/iptables -P FORWARD DROP

#BORRAR IP6TABLES ANTERIORES
/sbin/ip6tables -F
/sbin/ip6tables -X
/sbin/ip6tables -t nat -F

#DROPEAMOS TODO
/sbin/ip6tables -P INPUT DROP
/sbin/ip6tables -P OUTPUT DROP
/sbin/ip6tables -P FORWARD DROP

#Gardamos os logs
/sbin/iptables -A INPUT -j LOG

YO=10.11.49.47
COMPI1=10.11.49.55
COMPI2=10.11.49.58
YO51=10.11.51.47
COMPI1_51=10.11.51.55
COMPI2_51=10.11.51.58
YOIPV6=2002:a0b:312f::1
COMPI1_IPV6=2002:a0b:3137::1
COMPI2_IPV6=2002:a0b:313a::1
YOVPN=172.160.0.2
COMPI1VPN=172.160.0.1

#-------------- PERMITIMOS ---------------

#Aceptamos todo el tráfico de Localhost
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT

/sbin/iptables -A INPUT -i ens33 -p ipv6 -j ACCEPT
/sbin/iptables -A OUTPUT -o ens33 -p ipv6 -j ACCEPT

#Aceptamos cualquier paquete que provenga de conexiones ya establecidas
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

/sbin/ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#SSH (ens33)
/sbin/iptables -A INPUT -s $COMPI1 -d $YO -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI2 -d $YO -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI1 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI2 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

#SSH (ens34)
/sbin/iptables -A INPUT -s $COMPI1_51 -d $YO51 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI2_51 -d $YO51 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO51 -d $COMPI1_51 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO51 -d $COMPI2_51 -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

#HTTP
/sbin/iptables -A INPUT -s $COMPI1 -d $YO -p tcp --dport http -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI2 -d $YO -p tcp --dport http -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI1 -p tcp --dport http -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI2 -p tcp --dport http -m conntrack --ctstate NEW -j ACCEPT

#HTTPS
/sbin/iptables -A INPUT -s $COMPI1 -d $YO -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI2 -d $YO -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI1 -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI2 -p tcp --dport 433 -m conntrack --ctstate NEW -j ACCEPT

#Eduroam
/sbin/iptables -A INPUT -s 10.20.32.0/21 -d $YO -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s 10.30.8.0/21 -d $YO -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

#IPV6
/sbin/ip6tables -A INPUT -s $COMPI1_IPV6 -m conntrack --ctstate NEW -j ACCEPT
/sbin/ip6tables -A OUTPUT -d $COMPI1_IPV6 -m conntrack --ctstate NEW -j ACCEPT
/sbin/ip6tables -A INPUT -s $COMPI2_IPV6 -m conntrack --ctstate NEW -j ACCEPT
/sbin/ip6tables -A OUTPUT -d $COMPI2_IPV6 -m conntrack --ctstate NEW -j ACCEPT

#ICMP
/sbin/iptables -A INPUT -s $COMPI1 -d $YO -p icmp -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI2 -d $YO -p icmp -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI1VPN -p icmp -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI1 -p icmp -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI2 -p icmp -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -d $COMPI1VPN -p icmp -m conntrack --ctstate NEW -j ACCEPT

#TunelVPN
/sbin/iptables -A INPUT -s $COMPI1 -d $YO -p udp --dport 5555 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d $COMPI1 -p udp --sport 5555 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI1VPN -d $YOVPN -p tcp --dport 5555 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YOVPN -d $COMPI1VPN -p tcp --sport 5555 -m conntrack --ctstate NEW -j ACCEPT

#NTP (servidor)
/sbin/iptables -A INPUT -s $COMPI1 -d $YO -p udp --dport 123 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A INPUT -s $COMPI2 -d $YO -p udp --dport 123 -m conntrack --ctstate NEW -j ACCEPT

#Syslog (cliente)
/sbin/iptables -A OUTPUT -s $YO -d $COMPI1 -p tcp --dport 514 -m conntrack --ctstate NEW -j ACCEPT

#Nessus
/sbin/iptables -A INPUT -s 10.30.8.0/21 -d $YO -p tcp --dport 8834 -m conntrack --ctstate NEW -j ACCEPT

#Splunk
/sbin/iptables -A INPUT -s 10.30.8.0/21 -d $YO -p tcp --dport 8000 -m conntrack --ctstate NEW -j ACCEPT

#DNS
/sbin/iptables -A OUTPUT -s $YO -d 10.8.12.49 -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d 10.8.12.49 -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d 10.8.12.47 -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d 10.8.12.47 -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d 10.8.12.50 -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d 10.8.12.50 -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT

#APT
/sbin/iptables -A OUTPUT -s $YO -d deb.debian.org -m conntrack --ctstate NEW -j ACCEPT
/sbin/iptables -A OUTPUT -s $YO -d security.debian.org -m conntrack --ctstate NEW -j ACCEPT

#-----------POR SEGURIDAD------------
sleep 30

# Limpiar reglas existentes
/sbin/iptables -F
/sbin/iptables -X

/sbin/ip6tables -F
/sbin/ip6tables -X

# Restaurar políticas por defecto
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -P OUTPUT ACCEPT

/sbin/ip6tables -P INPUT ACCEPT
/sbin/ip6tables -P FORWARD ACCEPT
/sbin/ip6tables -P OUTPUT ACCEPT
