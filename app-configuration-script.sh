#!/bin/bash
# ---------------------------------------------------------
# This script aims to configure all the packages and 
# services which have been installed by test.sh script.
# This script is functionally seperated into 3 parts
# 	1. Configuration of Network Interfaces 
# 	2. Configuration of Revers Proxy Services 
# 	3. Configuration of Applications
# ---------------------------------------------------------


# Global variables list
EXT_INETRFACE="N/A"		# External interface variable
INT_INTERFACE="N/A"		# Internal interface variable


# ---------------------------------------------------------
# This function checks user. 
# Script must be executed by root user, otherwise it will
# output an error and terminate further execution.
# ---------------------------------------------------------
check_root ()
{
	echo -ne "Checking user root ... "
	if [ "$(whoami)" != "root" ]; then
		echo "Fail"
		echo "You need to be root to proceed. Exiting"
		exit 1
	else
		echo "OK"
	fi
}


# ---------------------------------------------------------
# Function to get varibales from /var/box_variables file
# Variables to be initialized are:
#   PLATFORM
#   HARDWARE
#   PROCESSOR
#   EXT_INTERFACE
#   INT_INTERFACE
# ----------------------------------------------------------
get_variables()
{
	echo "Initializing variables ..."
	if [ -e /var/box_variables ]; then
		PLATFORM=`cat /var/box_variables | grep "Platform" | awk {'print $2'}`
		HARDWARE=`cat /var/box_variables | grep "Hardware" | awk {'print $2'}`
		PROCESSOR=`cat /var/box_variables | grep "Processor" | awk {'print $2'}`
		EXT_INTERFACE=`cat /var/box_variables | grep "Ext_int" | awk {'print $2'}`
		INT_INTERFACE=`cat /var/box_variables | grep "Int_int" | awk {'print $2'}`

#	touch "/tmp/variables.log"

		if [ -z "$PLATFORM" -o -z "$HARDWARE" -o -z "$PROCESSOR" \
		     -o -z "$EXT_INTERFACE" -o -z "$INT_INTERFACE" ]; then
			echo "Error: Can not detect variables. Exiting"
			exit 5
		else
			echo "Platform:      $PLATFORM"
			echo "Hardware:      $HARDWARE"
			echo "Processor:     $PROCESSOR"
			echo "Ext Interface: $EXT_INTERFACE"
			echo "Int Interface: $INT_INTERFACE"
		fi 
	else 
		echo "Error: i cant find variables of the machine and operating system ,the installation script wasnt installed or failed, please check the Os requirements (at the moment only works in Debian 8 we are ongoing to ubuntu)" 
		exit 6
	fi
}


# ---------------------------------------------------------
# This functions configures hostname and static lookup
# table 
# ---------------------------------------------------------
configure_hosts()
{
echo "librerouter" > /etc/hostname

cat << EOF > /etc/hosts
#
# /etc/hosts: static lookup table for host names
#

#<ip-address>   <hostname.domain.org>   <hostname>
127.0.0.1       localhost.librenet librerouter localhost
10.0.0.1        librerouter.librenet
10.0.0.10       webmin.librenet
10.0.0.11       kibana.librenet
10.0.0.12       snorby.librenet
10.0.0.13       squidguard.librenet
10.0.0.250      easyrtc.librenet
10.0.0.251      yacy.librenet
10.0.0.252      friendica.librenet
10.0.0.253      owncloud.librenet
10.0.0.254      mailpile.librenet
EOF

}


# ---------------------------------------------------------
# This function configures internal and external interfaces
# ---------------------------------------------------------
configure_interfaces()
{
	# Network interfaces configuration for 
	# Physical/Virtual machine
if [ "$PROCESSOR" = "Intel" -o "$PROCESSOR" = "AMD" -o "$PROCESSOR" = "ARM" ]; then
	cat << EOF >  /etc/network/interfaces 
	# interfaces(5) file used by ifup(8) and ifdown(8)
	auto lo
	iface lo inet loopback

	#External network interface
	auto $EXT_INTERFACE
	allow-hotplug $EXT_INTERFACE
	iface $EXT_INTERFACE inet dhcp

	#Internal network interface
	auto $INT_INTERFACE
	allow-hotplug $INT_INTERFACE
	iface $INT_INTERFACE inet static
	    address 10.0.0.1
	    netmask 255.255.255.0
            network 10.0.0.0
    
	#Yacy
	auto $INT_INTERFACE:1
	allow-hotplug $INT_INTERFACE:1
	iface $INT_INTERFACE:1 inet static
	    address 10.0.0.251
            netmask 255.255.255.0

	#Friendica
	auto $INT_INTERFACE:2
	allow-hotplug $INT_INTERFACE:2
	iface $INT_INTERFACE:2 inet static
	    address 10.0.0.252
	    netmask 255.255.255.0
    
	#OwnCloud
	auto $INT_INTERFACE:3
	allow-hotplug $INT_INTERFACE:3
	iface $INT_INTERFACE:3 inet static
	    address 10.0.0.253
	    netmask 255.255.255.0
    
	#Mailpile
	auto $INT_INTERFACE:4
	allow-hotplug $INT_INTERFACE:4
	iface $INT_INTERFACE:4 inet static
	    address 10.0.0.254
	    netmask 255.255.255.0
	
	#Webmin
	auto $INT_INTERFACE:5
	allow-hotplug $INT_INTERFACE:5
	iface $INT_INTERFACE:5 inet static
	    address 10.0.0.10
	    netmask 255.255.255.0
	
	#EasyRTC
	auto $INT_INTERFACE:6
	allow-hotplug $INT_INTERFACE:6
	iface $INT_INTERFACE:6 inet static
	    address 10.0.0.250
            netmask 255.255.255.0

	#Kibana
	auto $INT_INTERFACE:7
	allow-hotplug $INT_INTERFACE:7
	iface $INT_INTERFACE:7 inet static
	    address 10.0.0.11
	    netmask 255.255.255.0

	#Snorby
	auto $INT_INTERFACE:8
	allow-hotplug $INT_INTERFACE:8
	iface $INT_INTERFACE:8 inet static
	    address 10.0.0.12
	    netmask 255.255.255.0

        #squidguard
        auto $INT_INTERFACE:9
        allow-hotplug $INT_INTERFACE:9
        iface $INT_INTERFACE:8 inet static
            address 10.0.0.13
            netmask 255.255.255.0
EOF
	# Network interfaces configuration for board
#	elif [ "$PROCESSOR" = "ARM" ]; then
#	cat << EOF >  /etc/network/interfaces 
#	# interfaces(5) file used by ifup(8) and ifdown(8)
#	auto lo
#	iface lo inet loopback
#
#	#External network interface
#	auto eth0
#	allow-hotplug eth0
#	iface eth0 inet dhcp
#
#	#External network interface
#	# wireless wlan0
#	auto wlan0
#	allow-hotplug wlan0
#	iface wlan0 inet dhcp
#
#	##External Network Bridge 
#	#auto br0
#	allow-hotplug br0
#	iface br0 inet dhcp   
#	    bridge_ports eth0 wlan0
#
#	#Internal network interface
#	auto eth1
#	allow-hotplug eth1
#	iface eth1 inet manual
#
#	#Internal network interface
#	# wireless wlan1
#	auto wlan1
#	allow-hotplug wlan1
#	iface wlan1 inet manual
#
#	#Internal network Bridge
#	auto br1
#	allow-hotplug br1
#	# Setup bridge
#	iface br1 inet static
#	    bridge_ports eth1 wlan1
#	    address 10.0.0.1
#	    netmask 255.255.255.0
#	    network 10.0.0.0
#    
#	#Yacy
#	auto eth1:1
#	allow-hotplug eth1:1
#	iface eth1:1 inet static
#	    address 10.0.0.251
#	    netmask 255.255.255.0
#
#	#Friendica
#	auto eth1:2
#	allow-hotplug eth1:2
#	iface eth1:2 inet static
#	    address 10.0.0.252
#	    netmask 255.255.255.0
#    
#	#OwnCloud
#	auto eth1:3
#	allow-hotplug eth1:3
#	iface eth1:3 inet static
#	    address 10.0.0.253
#	    netmask 255.255.255.0
#    
#	#Mailpile
#	auto eth1:4
#	allow-hotplug eth1:4
#	iface eth1:4 inet static
#	    address 10.0.0.254
#	    netmask 255.255.255.0
#	
#	#Webmin
#	auto eth1:5
#	allow-hotplug eth1:5
#	iface eth1:5 inet static
#	    address 10.0.0.10
#	    netmask 255.255.255.0
#
#	#EasyRTC
#	auto eth1:6
#	allow-hotplug eth1:6
#	iface eth1:6 inet static
#	    address 10.0.0.250
#	    netmask 255.255.255.0
#
#EOF

fi

# Restarting network configuration
/etc/init.d/networking restart
}


# ---------------------------------------------------------
# Function to configure DHCP server
# ---------------------------------------------------------
configure_dhcp()
{
echo "Configuring dhcp server ..."
echo "
ddns-update-style none;
option domain-name \"librerouter.librenet\";
option domain-name-servers 10.0.0.1;
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet 10.0.0.0 netmask 255.255.255.0 {
  range 10.0.0.100 10.0.0.200;
  option routers 10.0.0.1;
}
" > /etc/dhcp/dhcpd.conf

# Restarting dhcp server
service isc-dhcp-server restart
}


# ---------------------------------------------------------
# Function to configure blacklists
# ---------------------------------------------------------
configre_blacklists()
{
mkdir -p /etc/blacklists
cd /etc/blacklists

cat << EOF > /etc/blacklists/update-blacklists.sh
#!/bin/bash

#squidguard DB
mkdir -p /etc/blacklists/shallalist/tmp 
cd /etc/blacklists/shallalist/tmp
wget http://www.shallalist.de/Downloads/shallalist.tar.gz
tar xvzf shallalist.tar.gz ; res=\$?
rm -f shallalist.tar.gz
if [ "\$res" = 0 ]; then
 rm -fr /etc/blacklists/shallalist/ok
 mv /etc/blacklists/shallalist/tmp /etc/blacklists/shallalist/ok
else
 rm -fr /etc/blacklists/shallalist/tmp 
fi

mkdir -p /etc/blacklists/urlblacklist/tmp
cd /etc/blacklists/urlblacklist/tmp
wget http://urlblacklist.com/cgi-bin/commercialdownload.pl?type=download\\&file=bigblacklist -O urlblacklist.tar.gz
tar xvzf urlblacklist.tar.gz ; res=\$?
rm -f urlblacklist.tar.gz
if [ "\$res" = 0 ]; then
 rm -fr /etc/blacklists/urlblacklist/ok
 mv /etc/blacklists/urlblacklist/tmp /etc/blacklists/urlblacklist/ok
else
 rm -fr /etc/blacklists/urlblacklist/tmp 
fi

mkdir -p /etc/blacklists/mesdk12/tmp
cd /etc/blacklists/mesdk12/tmp
wget http://squidguard.mesd.k12.or.us/blacklists.tgz
tar xvzf blacklists.tgz ; res=\$?
rm -f blacklists.tgz
if [ "\$res" = 0 ]; then
 rm -fr /etc/blacklists/mesdk12/ok
 mv /etc/blacklists/mesdk12/tmp /etc/blacklists/mesdk12/ok
else
 rm -fr /etc/blacklists/mesdk12/tmp 
fi

mkdir -p /etc/blacklists/capitole/tmp
cd /etc/blacklists/capitole/tmp
wget ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/publicite.tar.gz
tar xvzf publicite.tar.gz ; res=\$?
rm -f publicite.tar.gz
if [ "\$res" = 0 ]; then
 rm -fr /etc/blacklists/capitole/ok
 mv /etc/blacklists/capitole/tmp /etc/blacklists/capitole/ok
else
 rm -fr /etc/blacklists/capitole/tmp 
fi


# chown proxy:proxy -R /etc/blacklists/*

EOF

chmod +x /etc/blacklists/update-blacklists.sh
/etc/blacklists/update-blacklists.sh

cat << EOF > /etc/blacklists/blacklists-iptables.sh
#ipset implementation for nat
for i in \$(grep -iv [A-Z] /etc/blacklists/shallalist/ok/BL/adv/domains)
do
  iptables -t nat -I PREROUTING -i br1 -s 10.0.0.0/16 -p tcp -d \$i -j DNAT --to-destination 5.5.5.5
done
EOF

chmod +x /etc/blacklists/blacklists-iptables.sh
}


# ---------------------------------------------------------
# Function to configure mysql
# ---------------------------------------------------------
configure_mysql()
{
        echo "Configuring MySQL ..."
        # Getting MySQL password
        if grep "DB_PASS" /var/box_variables > /dev/null 2>&1; then
                MYSQL_PASS=`cat /var/box_variables | grep "DB_PASS" | awk {'print $2'}`
        else
                MYSQL_PASS=`pwgen 10 1`
                echo "DB_PASS: $MYSQL_PASS" >> /var/box_variables
                # Setting password
                mysqladmin -u root password $MYSQL_PASS
        fi
}


# ---------------------------------------------------------
# Function to configure banks direct access to Internet
# ---------------------------------------------------------
configure_banks_access()
{
touch /var/banks_ips.txt
echo "192.229.182.219
194.224.167.58
195.21.32.34
195.21.32.40
192.229.182.219
" > /var/banks_ips.txt

touch /var/banks_access.sh
cat << EOF > /var/banks_access.sh
#!/bin/bash
for i in \$(cat /var/banks_ips.txt)
do
iptables -t nat -I PREROUTING -i $INT_INTERFACE -p tcp -d \$i -j ACCEPT
done
EOF
chmod a+x /var/banks_access.sh
}


# ---------------------------------------------------------
# Function to configure iptables
# ---------------------------------------------------------
configure_iptables()
{

# Disabling ipv6 and enabling ipv4 forwarding
echo "
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
" > /etc/sysctl.conf

# Restarting sysctl
sysctl -p > /dev/null

cat << EOF > /etc/rc.local
#!/bin/sh

iptables -X
iptables -F
iptables -t nat -F
iptables -t filter -F

iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.10 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.11 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.12 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.13 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.250 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.251 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.252 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.253 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.254 -j ACCEPT
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p udp -d 10.0.0.1 --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 80 -j REDIRECT --to-ports 80
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 443 -j REDIRECT --to-ports 443
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.1 --dport 7000 -j REDIRECT --to-ports 7000

# to squid-i2p 
iptables -t nat -A OUTPUT     -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -m tcp --sport 80 -d 10.191.0.1 -j REDIRECT --to-ports 3128

# to squid-tor
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -d 10.0.0.0/8 -j DNAT --to 10.0.0.1:3129

# to squid http 
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --dport 80 -j DNAT --to 10.0.0.1:3130

# to squid https 
iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --dport 443 -j REDIRECT --to-ports 3131

# iptables nat
iptables -t nat -A POSTROUTING -o $EXT_INTERFACE -j MASQUERADE 

# Redirecting traffic to tor
#iptables -t nat -A PREROUTING -i eth0 -p tcp -d 10.0.0.0/8 --dport 80 --syn -j REDIRECT --to-ports 9040
#iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 53

# Redirecting http traffic to squid 
#iptables -t nat -A PREROUTING -i eth1 -p tcp ! -d 10.0.0.0/24 --dport 80 -j DNAT --to 10.0.0.1:3128
#iptables -t nat -A PREROUTING -i eth0 -p tcp ! -d 10.0.0.0/24 --dport 80 -j DNAT --to 10.0.0.1:3128

## i2p petitions 
#iptables -t nat -A OUTPUT     -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
#iptables -t nat -A PREROUTING -d 10.191.0.1 -p tcp --dport 80 -j REDIRECT --to-port 3128
#iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp -m tcp --sport 80 -d 10.191.0.1 -j REDIRECT --to-ports 3128 

## Allow surf onion zone
#iptables -t nat -A PREROUTING -p tcp -d 10.192.0.0/16 -j REDIRECT --to-port 9040
#iptables -t nat -A OUTPUT     -p tcp -d 10.192.0.0/16 -j REDIRECT --to-port 9040
#iptables -t nat -A PREROUTING -i $INT_INTERFACE -p tcp --syn -m multiport ! --dports 80 -j REDIRECT --to-ports 9040

## Enable Blacklist
#[ -e /etc/blacklists/blacklists-iptables.sh ] && /etc/blacklists/blacklists-iptables.sh &

# Configuring banks direct access
/var/banks_access.sh

# Stopping dnsmasq
kill -9 \`ps aux | grep dnsmasq | awk {'print \$2'} | sed -n '1p'\` \
2> /dev/null
service unbound restart

# Starting easyrtc
nohup nodejs /opt/easyrtc/server.js &

# Starting Mailpile
/usr/bin/screen -dmS mailpile_init /opt/Mailpile/mp

# Restarting i2p
/etc/init.d/i2p restart

# Restarting tor
/etc/init.d/tor restart

# Running uwsgi
uwsgi --ini /etc/uwsgi/uwsgi.ini

exit 0
EOF

chmod +x /etc/rc.local

/etc/rc.local
}


# ---------------------------------------------------------
# Function to configure TOR
# ---------------------------------------------------------
configure_tor()
{
echo "Configuring Tor server"
tordir=/var/lib/tor/hidden_service
for i in yacy owncloud friendica mailpile easyrtc 
do

# Setting user and group to debian-tor
mkdir -p $tordir/$i
chown debian-tor:debian-tor $tordir/$i -R
rm -f $tordir/$i/*

# Setting permission to 2740 "rwxr-s---"
chmod 2700 $tordir/*

done

# Setting RUN_DAEMON to yes
# waitakey
# $EDITOR /etc/default/tor 
sed "s~RUN_DAEMON=.*~RUN_DAEMON=\"yes\"~g" -i /etc/default/tor


rm -f /etc/tor/torrc
#cp /usr/share/tor/tor-service-defaults-torrc /etc/tor/torrc
echo "" > /usr/share/tor/tor-service-defaults-torrc

echo "Configuring Tor hidden services"

echo "
DataDirectory /var/lib/tor
PidFile /var/run/tor/tor.pid
RunAsDaemon 1
User debian-tor

ControlSocket /var/run/tor/control GroupWritable RelaxDirModeCheck
ControlSocketsGroupWritable 1
SocksPort unix:/var/run/tor/socks WorldWritable
SocksPort 127.0.0.1:9050

CookieAuthentication 1
CookieAuthFileGroupReadable 1
CookieAuthFile /var/run/tor/control.authcookie

Log notice file /var/log/tor/log

HiddenServiceDir /var/lib/tor/hidden_service/yacy
HiddenServicePort 80 127.0.0.1:8090

HiddenServiceDir /var/lib/tor/hidden_service/owncloud
HiddenServicePort 80 127.0.0.1:7070
HiddenServicePort 443 127.0.0.1:443

#HiddenServiceDir /var/lib/tor/hidden_service/prosody
#HiddenServicePort 5222 127.0.0.1:5222
#HiddenServicePort 5269 127.0.0.1:5269

HiddenServiceDir /var/lib/tor/hidden_service/friendica
HiddenServicePort 80 127.0.0.1:8181
HiddenServicePort 443 127.0.0.1:443

HiddenServiceDir /var/lib/tor/hidden_service/mailpile
HiddenServicePort 33411 127.0.0.1:33411

HiddenServiceDir /var/lib/tor/hidden_service/easyrtc
HiddenServicePort 80 127.0.0.1:8080

DNSPort   127.0.0.1:9053
VirtualAddrNetworkIPv4 10.0.0.0/8
AutomapHostsOnResolve 1
" >>  /etc/tor/torrc

service nginx stop 
sleep 10
service tor restart

LOOP_S=0
LOOP_N=0
while [ $LOOP_S -lt 1 ]
do
 if [ -e "/var/lib/tor/hidden_service/yacy/hostname" ]; then
   echo "Tor successfully configured"
   LOOP_S=1
 else
   sleep 1
   LOOP_N=$((LOOP_N + 1))
 fi
 # Wail up to 30 s for tor hidden services to become available
 if [ $LOOP_N -eq 60 ]; then
   echo "Error: Unable to configure tor. Exiting ..."
   exit 1 
 fi 
done
}


# ---------------------------------------------------------
# Function to configure I2P services
# ---------------------------------------------------------
configure_i2p()
{
echo "Configuring i2p services ..."
# echo "Changeing RUN_DAEMON ..."
# waitakey
# $EDITOR /etc/default/i2p
sed "s~RUN_DAEMON=.*~RUN_DAEMON=\"true\"~g" -i /etc/default/i2p
service i2p restart
}


# ---------------------------------------------------------
# Function to configure Unbound DNS server
# ---------------------------------------------------------
configure_unbound() 
{
echo '# Unbound configuration file for Debian.
#
# See the unbound.conf(5) man page.
#
# See /usr/share/doc/unbound/examples/unbound.conf for a commented
# reference config file.

server:
    # The following line will configure unbound to perform cryptographic
    # DNSSEC validation using the root trust anchor.
   
    # Specify the interface to answer queries from by ip address.
    interface: 10.0.0.1

    # Port to answer queries
    port: 53

    # Serve ipv4 requests
    do-ip4: yes

    # Serve ipv6 requests
    do-ip6: no

    # Enable UDP
    do-udp: yes

    # Enable TCP
    do-tcp: yes

    # Not to answer id.server and hostname.bind queries
    hide-identity: yes

    # Not to answer version.server and version.bind queries
    hide-version: yes

    # Use 0x20-encoded random bits in the query 
    use-caps-for-id: yes

    # Cache minimum time to live
    Cache-min-ttl: 3600

    # Cache maximum time to live
    cache-max-ttl: 86400

    # Perform prefetching
    prefetch: yes

    # Number of threads 
    num-threads: 2

    ## Unbound optimization ##

    # Number od slabs
    msg-cache-slabs: 4
    rrset-cache-slabs: 4
    infra-cache-slabs: 4
    key-cache-slabs: 4

    # Size pf cache memory
    rrset-cache-size: 128m
    msg-cache-size: 64m

    # Buffer size for UDP port 53
    so-rcvbuf: 1m

    # Unwanted replies maximum number
    unwanted-reply-threshold: 10000

    # Define which network ips are allowed to make queries to this server.
    access-control: 10.0.0.0/8 allow
    access-control: 127.0.0.1/8 allow
    access-control: 0.0.0.0/0 refuse

    # Configure DNSSEC validation
    # librenet, onion and i2p domains are not checked for DNSSEC validation
#    auto-trust-anchor-file: "/var/lib/unbound/root.key"
    do-not-query-localhost: no
#    domain-insecure: "librenet"
#    domain-insecure: "onion"
#    domain-insecure: "i2p"
    
#Local destinations
local-zone: "librenet" static
local-data: "librerouter.librenet. IN A 10.0.0.1"
local-data: "i2p.librenet. IN A 10.0.0.1"
local-data: "tahoe.librenet. IN A 10.0.0.1"
local-data: "webmin.librenet. IN A 10.0.0.10"
local-data: "kibana.librenet. IN A 10.0.0.11"
local-data: "snorby.librenet. IN A 10.0.0.12"
local-data: "squidguard.librenet. IN A 10.0.0.13"' > /etc/unbound/unbound.conf

    for i in $(ls /var/lib/tor/hidden_service/)
    do
    if [ $i == "easyrtc" ]; then
      echo "local-data: \"$i.librenet. IN A 10.0.0.250\"" \
      >> /etc/unbound/unbound.conf
    fi
    if [ $i == "yacy" ]; then
      echo "local-data: \"$i.librenet. IN A 10.0.0.251\"" \
      >> /etc/unbound/unbound.conf
    fi
    if [ $i == "friendica" ]; then
      echo "local-data: \"$i.librenet. IN A 10.0.0.252\"" \
      >> /etc/unbound/unbound.conf
    fi
    if [ $i == "owncloud" ]; then
      echo "local-data: \"$i.librenet. IN A 10.0.0.253\"" \
      >> /etc/unbound/unbound.conf
    fi
    if [ $i == "mailpile" ]; then
      echo "local-data: \"$i.librenet. IN A 10.0.0.254\"" \
      >> /etc/unbound/unbound.conf
    fi
    done

for i in $(ls /var/lib/tor/hidden_service/)
  do
  hn="$(cat /var/lib/tor/hidden_service/$i/hostname 2>/dev/null )"
  if [ -n "$hn" ]; then
    echo "local-zone: \"$hn.\" static" >> /etc/unbound/unbound.conf
    if [ $i == "easyrtc" ]; then
      echo "local-data: \"$hn. IN A 10.0.0.250\"" >> /etc/unbound/unbound.conf
    fi
    if [ $i == "yacy" ]; then
      echo "local-data: \"$hn. IN A 10.0.0.251\"" >> /etc/unbound/unbound.conf
    fi
    if [ $i == "friendica" ]; then
      echo "local-data: \"$hn. IN A 10.0.0.252\"" >> /etc/unbound/unbound.conf
    fi
    if [ $i == "owncloud" ]; then
      echo "local-data: \"$hn. IN A 10.0.0.253\"" >> /etc/unbound/unbound.conf
    fi
    if [ $i == "mailpile" ]; then
      echo "local-data: \"$hn. IN A 10.0.0.254\"" >> /etc/unbound/unbound.conf
    fi
  fi
  done

echo '
# I2P domains will be resolved us 10.191.0.1 
local-zone: "i2p." redirect
local-data: "i2p. IN A 10.191.0.1"

# Include social networks domains list configuration
include: /etc/unbound/socialnet_domain.list.conf

# Include search engines domains list configuration
include: /etc/unbound/searchengines_domain.list.conf

# Include webmail domains list configuration
include: /etc/unbound/webmail_domain.list.conf

# Include chat domains list configuration
include: /etc/unbound/chat_domain.list.conf

# Include storage domains list configuration
include: /etc/unbound/storage_domain.list.conf

# Include block domains list configuration
include: /etc/unbound/block_domain.list.conf
 
# .ounin domains will be resolved by TOR DNS 
forward-zone:
    name: "onion"
    forward-addr: 127.0.0.1@9053

# Forward rest of zones to DjDNS
forward-zone:
    name: "."
    forward-addr: 127.0.0.1@9053

' >> /etc/unbound/unbound.conf

# Extracting classified domain list package
echo "Extracting files ..."
tar -xf shallalist.tar.gz
if [ $? -ne 0 ]; then
	echo "Error: Unable to extract domains list. Exithing"
	exit 6
fi

# Configuring social network domains list
echo "Configuring domain list ..."
find BL/socialnet -name domains -exec cat {} \; > socialnet_domain.list
find BL/searchengines -name domains -exec cat {} \; > searchengines_domain.list
find BL/webmail -name domains -exec cat {} \; > webmail_domain.list
find BL/chat -name domains -exec cat {} \; > chat_domain.list
find BL/downloads -name domains -exec cat {} \; > storage_domain.list
find BL/spyware -name domains -exec cat {} \; > block_domain.list
find BL/redirector -name domains -exec cat {} \; >> block_domain.list
find BL/tracker -name domains -exec cat {} \; >> block_domain.list

# Deleting old files
rm -rf shallalist 	

# Creating chat domains list configuration file
cat chat_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.250\""'} \
> /etc/unbound/chat_domain.list.conf
cat chat_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.250\""'} \
>> /etc/unbound/chat_domain.list.conf

# Adding skype to chat domain list
echo "local-data: \"skype.com IN A 10.0.0.250\"
local-data: \"www.skype.com IN A 10.0.0.250\"
" >> /etc/unbound/chat_domain.list.conf

# Creating search engines domains list configuration file
cat searchengines_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.251\""'} \
> /etc/unbound/searchengines_domain.list.conf
cat searchengines_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.251\""'} \
>> /etc/unbound/searchengines_domain.list.conf

# Creating social networks domains list configuration file
cat socialnet_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.252\""'} \
> /etc/unbound/socialnet_domain.list.conf
cat socialnet_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.252\""'} \
>> /etc/unbound/socialnet_domain.list.conf

# Creating storage domains list configuration file
cat storage_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.253\""'} \
> /etc/unbound/storage_domain.list.conf
cat storage_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.253\""'} \
>> /etc/unbound/storage_domain.list.conf

# Creating  webmail domains list configuration file
cat webmail_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.254\""'} \
> /etc/unbound/webmail_domain.list.conf
cat webmail_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.254\""'} \
>> /etc/unbound/webmail_domain.list.conf

# Creating  block domains list configuration file
cat block_domain.list | \
awk {'print "local-data: \"" $1 " IN A 10.0.0.10\""'} \
> /etc/unbound/block_domain.list.conf
cat block_domain.list | \
awk {'print "local-data: \"www." $1 " IN A 10.0.0.10\""'} \
>> /etc/unbound/block_domain.list.conf

# Deleting old files
rm -rf socialnet_domain.list
rm -rf searchengines_domain.list
rm -rf webmail_domain.list
rm -rf chat_domain.list
rm -rf storage_domain.list
rm -rf block_domain.list

# Updating DNSSEC root trust anchor
unbound-anchor -a "/var/lib/unbound/root.key"

# There is a need to stop dnsmasq before starting unbound
echo "Stoping dnsmasq ..."
if ps aux | grep -w "dnsmasq" | grep -v "grep" > /dev/null;   then
	kill -9 `ps aux | grep dnsmasq | awk {'print $2'} | sed -n '1p'`
fi

#     echo "
#	# Stopping dnsmasq
#	kill -9 \`ps aux | grep dnsmasq | awk {'print \$2'} | sed -n '1p'\` \
#	2> /dev/null
#	" >> /etc/rc.local
#
#	echo "service unbound restart" >> /etc/rc.local

echo "Starting Unbound DNS server ..."
service unbound restart
if ps aux | grep -w "unbound" | grep -v "grep" > /dev/null; then
	echo "Unbound DNS server successfully started."
else
	echo "Error: Unable to start unbound DNS server. Exiting"
	exit 3
fi
}


# ---------------------------------------------------------
# Function to configure Friendica local service
# ---------------------------------------------------------
configure_friendica()
{
echo "Configuring Friendica local service ..."
if [ ! -e  /var/lib/mysql/frndcdb ]; then

  # Defining MySQL user and password variables
# MYSQL_PASS="librerouter"
  MYSQL_USER="root"

  # Creating MySQL database frndc for friendica local service
  echo "CREATE DATABASE frndcdb;" \
  | mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" 
fi

  # Inserting friendica database
  mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" frndcdb < /var/www/friendica/database.sql

if [ -z "$(grep "friendica/include/poller" /etc/crontab)" ]; then
    echo '*/10 * * * * /usr/bin/php /var/www/friendica/include/poller.php' >> /etc/crontab
fi

# Creating friendica configuration
echo "
<?php

\$db_host = 'localhost';
\$db_user = 'root';
\$db_pass = '$MYSQL_PASS';
\$db_data = 'frndcdb';

\$a->path = '';
\$default_timezone = 'America/Los_Angeles';
\$a->config['sitename'] = \"My Friend Network\";
\$a->config['register_policy'] = REGISTER_OPEN;
\$a->config['register_text'] = '';
\$a->config['admin_email'] = 'admin@librerouter.com';
\$a->config['max_import_size'] = 200000;
\$a->config['system']['maximagesize'] = 800000;
\$a->config['php_path'] = '/usr/bin/php';
\$a->config['system']['huburl'] = '[internal]';
\$a->config['system']['rino_encrypt'] = true;
\$a->config['system']['theme'] = 'duepuntozero';
\$a->config['system']['no_regfullname'] = true;
\$a->config['system']['directory'] = 'http://dir.friendi.ca';
" > /var/www/friendica/.htconfig.php

}


# ---------------------------------------------------------
# Function to configure EasyRTC local service
# ---------------------------------------------------------
configure_easyrtc()
{
echo "Starting EasyRTC local service ..."
if [ ! -e /opt/easyrtc/server.js ]; then
    echo "Can not find EasyRTC server in /opt/eastrtc directory. Exiting ..."
    exit 4
fi

cat << EOF > /opt/easyrtc/server.js 
    // Load required modules
    var https   = require("https");     // https server core module
    var fs      = require("fs");        // file system core module
    var express = require("express");   // web framework external module
    var io      = require("socket.io"); // web socket external module
    var easyrtc = require("easyrtc");   // EasyRTC external module

    // Setup and configure Express http server. Expect a subfolder called "static" to be the web root.
    var httpApp = express();
    httpApp.use(express.static(__dirname + "/static/"));

    // Start Express https server on port 8443
    var webServer = https.createServer(
    {
        key:  fs.readFileSync("/etc/ssl/nginx/easyrtc.key"),
        cert: fs.readFileSync("/etc/ssl/nginx/easyrtc.crt")
    },
    httpApp).listen(8443);

    // Start Socket.io so it attaches itself to Express server
    var socketServer = io.listen(webServer, {"log level":1});

    // Start EasyRTC server
    var rtc = easyrtc.listen(httpApp, socketServer);
EOF

sed -i '/function connect() {/a easyrtc.setSocketUrl(":8443");' /opt/easyrtc/node_modules/easyrtc/demos/js/*.js

cd /opt/easyrtc

# Starting EasyRTC server
nohup nodejs server &

echo ""
cd
}


# ---------------------------------------------------------
# Function to configure Owncloud local service 
# ---------------------------------------------------------
configure_owncloud()
{
echo "Configuring Owncloud local service ..."

# Getting owncloud onion service name
SERVER_OWNCLOUD="$(cat /var/lib/tor/hidden_service/owncloud/hostname 2>/dev/null)"

# Getting owncloud files in web server root directory
if [ ! -e  /var/www/owncloud ]; then
 if [ -e /ush/share/owncloud ]; then
   cp -r /usr/share/owncloud /var/www/owncloud
 else
   if [ -e /opt/owncloud ]; then
     cp -r /opt/owncloud /var/www/owncloud
   fi
 fi
fi

chown -R www-data /var/www/owncloud

}


# ---------------------------------------------------------
# Function to configure Privoxy
# --------------------------------------------------------
configure_privoxy()
{
/etc/init.d/privoxy stop
rm -f /etc/rc?.d/*privoxy*

#Privoxy I2P

cat << EOF > /etc/privoxy/config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action # Actions that are applied to all sites and maybe overruled later on.
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
filterfile user.filter      # User customizations
logfile logfile
listen-address  127.0.0.1:8118
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
forward .i2p 127.0.0.1:4444
EOF

#Privoxy TOR

cat << EOF > /etc/privoxy/config-tor 
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
logfile logfile
user-manual /usr/share/doc/privoxy/user-manual
listen-address 127.0.0.1:8119
toggle 0
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
forward-socks5t / 127.0.0.1:9050 .
max-client-connections 4096
EOF

cp /etc/init.d/privoxy /etc/init.d/privoxy-tor
sed "s~Provides:.*~Provides:          privoxy-tor~g" -i  /etc/init.d/privoxy-tor
sed "s~PIDFILE=.*~PIDFILE=/var/run/\$NAME-tor.pid~g" -i  /etc/init.d/privoxy-tor
sed "s~CONFIGFILE=.*~CONFIGFILE=/etc/privoxy/config-tor~g" -i /etc/init.d/privoxy-tor
sed "s~SCRIPTNAME=.*~SCRIPTNAME=/etc/init.d/\$NAME-tor~g" -i /etc/init.d/privoxy-tor

update-rc.d privoxy-tor defaults

echo "Restarting privoxy-tor ..."
service privoxy-tor restart

echo "Restarting privoxy-i2p ..."
service privoxy restart

}


# ---------------------------------------------------------
# Function to configure squid
# ---------------------------------------------------------
configure_squid()
{
echo "Configuring squid server ..."

# Generating certificates for ssl connection
echo "Generating certificates ..."
if [ ! -e /etc/squid/ssl_cert ]; then
mkdir /etc/squid/ssl_cert
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509  \
	-keyout /etc/squid/ssl_cert/squid.key \
        -out /etc/squid/ssl_cert/squid.crt -batch
chown -R proxy:proxy /etc/squid/ssl_cert
chmod -R 777 /etc/squid/ssl_cert
fi

echo "Creating log directory for Squid..."
mkdir /var/log/squid
chown -R proxy:proxy /var/log/squid
chmod -R 777 /var/log/squid

echo "Calling Squid to create swap directories and initialize cert cache dir..."
squid -z
if [ -d "/var/cache/squid/ssl_db" ]; then
	rm -rf /var/cache/squid/ssl_db
fi
/lib/squid/ssl_crtd -c -s /var/cache/squid/ssl_db
chown -R proxy:proxy /var/cache/squid/ssl_db
chmod -R 777 /var/cache/squid/ssl_db

# squid configuration
echo "Creating squid conf file ..."
echo "
acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT
acl librenetwork src 10.0.0.0/24
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localhost
http_access allow librenetwork
http_access deny all

# squidGuard configuration
url_rewrite_program /usr/bin/squidGuard -c /etc/squidguard/squidGuard.conf

# http configuration
http_port 10.0.0.1:3130 intercept
coredump_dir /var/spool/squid

# https configuration
https_port 10.0.0.1:3131 intercept ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=4MB cert=/etc/squid/ssl_cert/squid.crt key=/etc/squid/ssl_cert/squid.key
always_direct allow all

# SSL Proxy options
ssl_bump server-first all
sslproxy_cert_error allow all
sslproxy_cert_adapt setCommonName ssl::certDomainMismatch
sslproxy_options ALL,SINGLE_DH_USE,NO_SSLv3,NO_SSLv2 

# Refresh patterns
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\\?) 0     0%      0
refresh_pattern .               0       20%     4320

# sslcrtd configuration
sslcrtd_program /lib/squid/ssl_crtd -s /var/cache/squid/ssl_db -M 4MB
sslcrtd_children 5

# icap configuration
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_encode off
icap_client_username_header X-Authenticated-User
icap_preview_enable on
icap_preview_size 1024
icap_service service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_req allow all
icap_service service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_resp allow all
" > /etc/squid/squid.conf

echo "Configuring squid startup file ..."
if [ ! -e /etc/squid/squid3.rc ]; then
        echo "Could not find squid srartup script. Exiting ..."
        exit 8
else
	rm -rf /etc/init.d/squid*
        cp /etc/squid/squid3.rc /etc/init.d/squid
	sed "s~Provides:.*~Provides:          squid~g" -i  /etc/init.d/squid
	sed "s~NAME=.*~NAME=squid~g" -i  /etc/init.d/squid
	sed "s~DAEMON=.*~DAEMON=/usr/sbin/squid~g" -i  /etc/init.d/squid
	sed "s~PIDFILE=.*~PIDFILE=/var/run/squid.pid~g" \
	-i  /etc/init.d/squid
	sed "s~CONFIG=.*~CONFIG=/etc/squid/squid.conf~g" \
	-i /etc/init.d/squid
	chmod +x /etc/init.d/squid
fi
	
update-rc.d squid start defaults
echo "Restarting squid server ..."
service squid restart

# squid TOR

echo "Creating squid-tor conf file ..."
cat << EOF > /etc/squid/squid-tor.conf 
# Tor acl
acl tor_url dstdomain .onion

# Privoxy+Tor access rules 
never_direct allow tor_url

# Local Privoxy is cache parent 
cache_peer 127.0.0.1 parent 8119 0 no-query no-digest default

cache_peer_access 127.0.0.1 allow tor_url
cache_peer_access 127.0.0.1 deny all

#acl manager proto cache_object
acl localhost src 127.0.0.1/32 
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 

acl localnet src 10.0.0.0/8     # RFC1918 possible internal network

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

http_access allow localnet
http_access allow localhost
http_access allow all
http_access deny all

#http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access deny all

http_port 3129 accel vhost allow-direct

hierarchy_stoplist cgi-bin ?

never_direct allow all

cache_store_log none

pid_filename /var/run/squid-tor.pid

cache_log /var/log/squid/cache.log

coredump_dir /var/spool/squid

#url_rewrite_program /usr/bin/squidGuard

no_cache deny all

# icap configuration
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_encode off
icap_client_username_header X-Authenticated-User
icap_preview_enable on
icap_preview_size 1024
icap_service service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_req allow all
icap_service service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_resp allow all
EOF

echo "Configuring squid-tor startup file ..."
cp /etc/init.d/squid /etc/init.d/squid-tor
sed "s~Provides:.*~Provides:          squid-tor~g" -i  /etc/init.d/squid-tor
sed "s~PIDFILE=.*~PIDFILE=/var/run/squid-tor.pid~g" -i  /etc/init.d/squid-tor
sed "s~CONFIG=.*~CONFIG=/etc/squid/squid-tor.conf~g" -i /etc/init.d/squid-tor

update-rc.d squid-tor start defaults
echo "Restarting squid-tor ..."
service squid-tor restart

#Squid I2P

echo "Creating squid-i2p conf file ..."
cat << EOF > /etc/squid/squid-i2p.conf
cache_peer 127.0.0.1 parent 8118 7 no-query no-digest

#acl manager proto cache_object
acl localhost src 127.0.0.1/32 
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 

acl localnet src 10.0.0.0/8     # RFC1918 possible internal network

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

http_access allow localnet
http_access allow localhost
http_access allow all
http_access deny all

http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access deny all

http_port 3128 accel vhost allow-direct

hierarchy_stoplist cgi-bin ?

never_direct allow all

cache_store_log none

pid_filename /var/run/squid-i2p.pid

cache_log /var/log/squid/cache.log

coredump_dir /var/spool/squid

#url_rewrite_program /usr/bin/squidGuard

no_cache deny all

# icap configuration
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_encode off
icap_client_username_header X-Authenticated-User
icap_preview_enable on
icap_preview_size 1024
icap_service service_req reqmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_req allow all
icap_service service_resp respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access service_resp allow all
EOF

echo "Configuring squid-i2p startup file ..."
cp /etc/init.d/squid /etc/init.d/squid-i2p
sed "s~Provides:.*~Provides:          squid-i2p~g" -i  /etc/init.d/squid-i2p
sed "s~PIDFILE=.*~PIDFILE=/var/run/squid-i2p.pid~g" -i  /etc/init.d/squid-i2p
sed "s~CONFIG=.*~CONFIG=/etc/squid/squid-i2p.conf~g" -i /etc/init.d/squid-i2p

update-rc.d squid-i2p start defaults
echo "Restarting squid-i2p ..."
service squid-i2p restart
}


# ---------------------------------------------------------
# Function to configure c-icap
# ---------------------------------------------------------
configure_c_icap()
{
echo "Configuring c-icap ..."

# Making c-icap daemon run automatically on startup
echo "
# Defaults for c-icap initscript
# sourced by /etc/init.d/c-icap
# installed at /etc/default/c-icap by the maintainer scripts

# Should c-icap daemon run automatically on startup? (default: no)
START=yes

# Additional options that are passed to the Daemon.
DAEMON_ARGS=\"\"
" > /etc/default/c-icap

# c-icap configuration
echo "
PidFile /var/run/c-icap/c-icap.pid
CommandsSocket /var/run/c-icap/c-icap.ctl
Timeout 300
MaxKeepAliveRequests 100
KeepAliveTimeout 600
StartServers 3
MaxServers 10
MinSpareThreads     10
MaxSpareThreads     20
ThreadsPerChild     10
MaxRequestsPerChild  0
Port 1344
User c-icap
Group c-icap
ServerAdmin admin@librerouter.com
ServerName librerouter
TmpDir /tmp
MaxMemObject 131072
DebugLevel 1
TemplateDir /usr/share/c_icap/templates/
TemplateDefaultLanguage en
LoadMagicFile /etc/c-icap/c-icap.magic
RemoteProxyUsers off
RemoteProxyUserHeader X-Authenticated-User
RemoteProxyUserHeaderEncoded on
ServerLog /var/log/c-icap/server.log
AccessLog /var/log/c-icap/access.log
Service squidclamav squidclamav.so
Service echo srv_echo.so
" > /etc/c-icap/c-icap.conf

# Modules directory in Intel
if [ "$PROCESSOR" = "Intel" ]; then
echo "
ModulesDir /usr/lib/x86_64-linux-gnu/c_icap
ServicesDir /usr/lib/x86_64-linux-gnu/c_icap
" >> /etc/c-icap/c-icap.conf
fi

# Modules directory in ARM
if [ "$PROCESSOR" = "ARM" ]; then
echo "
ModulesDir /usr/lib/arm-linux-gnueabihf/c_icap
ServicesDir /usr/lib/arm-linux-gnueabihf/c_icap
" >> /etc/c-icap/c-icap.conf
fi

echo "Restarting c-icap service ..."
service c-icap restart
}


# ---------------------------------------------------------
# Function to configure squidclamav
# ---------------------------------------------------------
configure_squidclamav()
{
echo "Configuring squidclamav ..."
echo "
maxsize 5000000
redirect http://localhost/virus_warning_page
clamd_local /var/run/clamav/clamd.ctl
#clamd_ip 10.0.0.1,127.0.0.1
#clamd_port 3310
timeout 1
logredir 0
dnslookup 1
safebrowsing 0
" > /etc/squidclamav.conf

echo "Restarting clamav daemon ..."
service clamav-daemon restart
}


# ---------------------------------------------------------
# Function to configure squidguard
# ---------------------------------------------------------
configure_squidguard()
{

echo "Configuring squidguard ..."

mkdir -p /etc/squidguard
cat << EOF > /etc/squidguard/squidGuard.conf
#
# CONFIG FILE FOR SQUIDGUARD
#

dbhome /usr/local/squidGuard/db/blacklists
logdir /usr/local/squidGuard/logs

dest ads {
        domainlist ads/domains
        urllist ads/urls
        }

dest proxy {
        domainlist proxy/domains
        urllist proxy/urls
        }

dest spyware {
        domainlist spyware/domains
        urllist spyware/urls
        }

dest redirector {
        domainlist redirector/domains
        urllist redirector/urls
        }

dest suspect {
        domainlist suspect/domains
        urllist suspect/urls
        }

# Access control 
acl {
        default {
                pass !ads !proxy !spyware !redirector !suspect all
                redirect http://localhost/block.html
        }
 }
EOF

squidGuard -C all
chmod -R a+rw /usr/local/squidGuard/db/*
}


# ---------------------------------------------------------
# Function to configure squidguardmgr
# ---------------------------------------------------------
configure_squidguardmgr()
{
# uwcgi configuretion
cat << EOF > /etc/uwsgi/uwsgi.ini
[uwsgi]
plugins = cgi
threads = 20
socket = 127.0.0.1:9000
cgi=/var/www/squidguardmgr 
cgi-allowed-ext = .cgi
EOF

}


# ---------------------------------------------------------
# Function to configure e2guardian
# ---------------------------------------------------------
configure_e2guardian()
{

echo "Configuring e2guardian ..."

cat << EOF > /etc/e2guardian/e2guardian.conf
languagedir = '/usr/share/e2guardian/languages'
language = 'ukenglish'
loglevel = 3
logexceptionhits = 2
logfileformat = 1
loglocation = '/var/log/e2guardian/access.log'
dstatlocation = '/var/log/e2guardian/dstats.log'
filterip = 127.0.0.1
filterports = 8080
proxyip = 127.0.0.1
proxyport = 4444
proxytimeout = 20
proxyexchange = 20
pcontimeout = 55
usecustombannedimage = on
custombannedimagefile = '/usr/share/e2guardian/transparent1x1.gif'
usecustombannedflash = on
custombannedflashfile = '/usr/share/e2guardian/blockedflash.swf'
filtergroups = 1
filtergroupslist = '/etc/e2guardian/lists/filtergroupslist'
bannediplist = '/etc/e2guardian/lists/bannediplist'
exceptioniplist = '/etc/e2guardian/lists/exceptioniplist'
showweightedfound = on
urlcachenumber = 1000
urlcacheage = 900
scancleancache = on
phrasefiltermode = 2
preservecase = 0
hexdecodecontent = off
forcequicksearch = off
reverseaddresslookups = off
reverseclientiplookups = off
logclienthostnames = off
prefercachedlists = off
maxcontentfiltersize = 256
maxcontentramcachescansize = 2000
maxcontentfilecachescansize f= 20000
filecachedir = '/tmp'
deletedownloadedtempfiles = on
initialtrickledelay = 20
trickledelay = 10
downloadmanager = '/etc/e2guardian/downloadmanagers/fancy.conf'
downloadmanager = '/etc/e2guardian/downloadmanagers/default.conf'
contentscannertimeout = 60
contentscanexceptions = off
recheckreplacedurls = off
forwardedfor = off
usexforwardedfor = off
logconnectionhandlingerrors = on
logsslerrors = off
logchildprocesshandling = off
maxchildren = 180
minchildren = 20
minsparechildren = 16
preforkchildren = 10
maxsparechildren = 32
maxagechildren = 500
maxips = 0
ipcfilename = '/tmp/.e2guardianipc'
urlipcfilename = '/tmp/.e2guardianurlipc'
ipipcfilename = '/tmp/.e2guardianipipc'
nodaemon = off
nologger = off
logadblocks = off
loguseragent = off
daemonuser = 'proxy'
daemongroup = 'e2guardian'
softrestart = off
mailer = '/usr/sbin/sendmail -t'
EOF

# Creating log file
touch /var/log/e2guardian/access.log
chmod a+rw /var/log/e2guardian/access.log

# Creating e2guardian group
groupadd e2guardian

# killing all instances
e2guardian -q

# Running e2guardian
e2guardian
}


# ---------------------------------------------------------
# Function to configure postfix mail service
# ---------------------------------------------------------
configure_postfix()
{
# Configurinf postfix mail service
echo "Configuring postfix ..."

echo "
mtpd_banner = \$myhostname ESMTP \$mail_name (Debian/GNU)
biff = no
append_dot_mydomain = no 
readme_directory = no
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = librerouter.librenet
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = librerouter.librenet, localhost.librenet, localhost
relayhost =
mynetworks = 127.0.0.0/8, 10.0.0.0/24
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
" > /etc/postfix/main.cf

echo "Restarting postfix ..."
service postfix restart
}


# ---------------------------------------------------------
# Function to start mailpile local service
# ---------------------------------------------------------
configure_mailpile()
{
echo "Configuring Mailpile local service ..."
export MAILPILE_HOME=.local/share/Mailpile
if [ -e $MAILPIEL_HOME/default/mailpile.cfg ]; then
  echo "Configuration file does not exist. Exiting ..."
  exit 6
fi

# Make Mailpile a service with upstart
echo "
description \"Mailpile Webmail Client\"
author      \"Sharon Campbell\"

start on filesystem or runlevel [2345]
stop on shutdown

script

    echo \$\$ > /var/run/mailpile.pid
    exec /usr/bin/screen -dmS mailpile_init /var/Mailpile/mp

end script

pre-start script
    echo \"[\`date\`] Mailpile Starting\" >> /var/log/mailpile.log
end script

pre-stop script
    rm /var/run/mailpile.pid
    echo \"[\`date\`] Mailpile Stopping\" >> /var/log/mailpile.log
end script
" > /etc/init/mailpile.conf
 
echo "Starting Mailpile local service ..."
/usr/bin/screen -dmS mailpile_init /opt/Mailpile/mp
}


# ---------------------------------------------------------
# Function to configure nginx web server
# ---------------------------------------------------------
configure_nginx() 
{
echo "Configuring Nginx ..."
mkdir -p /etc/ssl/nginx/

echo "upstream php-handler {
  server 127.0.0.1:9000;
  #server unix:/var/run/php5-fpm.sock;
  }
" > /etc/nginx/sites-enabled/php-fpm

echo "server {
  listen 80 default_server;
  return 301 http://librerouter.librenet;
}

server {
  listen 80;
  server_name box.librenet;
  return 301 http://librerouter.librenet;
}
" > /etc/nginx/sites-enabled/default

echo "server {
  listen 10.0.0.1:80;
  server_name librerouter.librenet;
  root /var/www/html;
  index index.html;

        location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files \$uri =404;
                       root /usr/share/;
                       fastcgi_pass unix:/var/run/php5-fpm.sock;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                       include /etc/nginx/fastcgi_params;
               }
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }
        }
        location /phpMyAdmin {
               rewrite ^/* /phpmyadmin last;
        }
}
" > /etc/nginx/sites-enabled/librerouter

# Configuring Yacy virtual host
echo "Configuring Yacy virtual host ..."

# Getting Tor hidden service yacy hostname
SERVER_YACY="$(cat /var/lib/tor/hidden_service/yacy/hostname 2>/dev/null)"

# Generating keys and certificates for https connection
echo "Generating keys and certificates for Yacy ..."
if [ ! -e /etc/ssl/nginx/$SERVER_YACY.key -o ! -e /etc/ssl/nginx/$SERVER_YACY.csr -o ! -e  /etc/ssl/nginx/$SERVER_YACY.crt ]; then
    openssl genrsa -out /etc/ssl/nginx/$SERVER_YACY.key 2048 -batch
    openssl req -new -key /etc/ssl/nginx/$SERVER_YACY.key -out /etc/ssl/nginx/$SERVER_YACY.csr -batch
    cp /etc/ssl/nginx/$SERVER_YACY.key /etc/ssl/nginx/$SERVER_YACY.key.org 
    openssl rsa -in /etc/ssl/nginx/$SERVER_YACY.key.org -out /etc/ssl/nginx/$SERVER_YACY.key 
    openssl x509 -req -days 365 -in /etc/ssl/nginx/$SERVER_YACY.csr -signkey /etc/ssl/nginx/$SERVER_YACY.key -out /etc/ssl/nginx/$SERVER_YACY.crt 
fi

# Creating Yacy virtual host configuration
echo "
# Redirect yacy.librenet to Tor hidden service yacy
server {
        listen 10.0.0.251:80;
        server_name yacy.librenet;
	rewrite ^/search(.*) http://\$server_name/yacysearch.html?query=\$arg_q? last;
location / {
    proxy_pass       http://127.0.0.1:8090;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}

# Redirect connections from 10.0.0.251 to Tor hidden service yacy
server {
        listen 10.0.0.251;
        server_name _;
        return 301 http://yacy.librenet;
}

# Redirect connections to yacy running on 127.0.0.1:8090
#server {
#        listen 10.0.0.251:80;
#        server_name $SERVER_YACY;
#
#location / {
#    proxy_pass       http://127.0.0.1:8090;
#    proxy_set_header Host      \$host;
#    proxy_set_header X-Real-IP \$remote_addr;
#  }
#}

# Redirect https connections to http
#server {
#        listen 10.0.0.251:443 ssl;
#        server_name $SERVER_YACY;
#        ssl_certificate /etc/ssl/nginx/$SERVER_YACY.crt;
#        ssl_certificate_key /etc/ssl/nginx/$SERVER_YACY.key;
#        return 301 http://$SERVER_YACY;
#}
server {
        listen 10.0.0.251:443 ssl;
        server_name yacy.librenet;
        ssl_certificate /etc/ssl/nginx/$SERVER_YACY.crt;
        ssl_certificate_key /etc/ssl/nginx/$SERVER_YACY.key;
        rewrite ^/search(.*) http://\$server_name/yacysearch.html?query=\$arg_q? last;

location / {
    proxy_pass       http://127.0.0.1:8090;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
" > /etc/nginx/sites-enabled/yacy

# Configuring Friendica virtual host
echo "Configuring Friendica virtual host ..."

# Getting Tor hidden service friendica hostname
SERVER_FRIENDICA="$(cat /var/lib/tor/hidden_service/friendica/hostname 2>/dev/null)"

# Generating keys and certificates for https connection
echo "Generating keys and certificates for Friendica ..."
if [ ! -e /etc/ssl/nginx/$SERVER_FRIENDICA.key -o ! -e /etc/ssl/nginx/$SERVER_FRIENDICA.csr -o ! -e  /etc/ssl/nginx/$SERVER_FRIENDICA.crt ]; then
    openssl genrsa -out /etc/ssl/nginx/$SERVER_FRIENDICA.key 2048 -batch
    openssl req -new -key /etc/ssl/nginx/$SERVER_FRIENDICA.key -out /etc/ssl/nginx/$SERVER_FRIENDICA.csr -batch
    cp /etc/ssl/nginx/$SERVER_FRIENDICA.key /etc/ssl/nginx/$SERVER_FRIENDICA.key.org 
    openssl rsa -in /etc/ssl/nginx/$SERVER_FRIENDICA.key.org -out /etc/ssl/nginx/$SERVER_FRIENDICA.key 
    openssl x509 -req -days 365 -in /etc/ssl/nginx/$SERVER_FRIENDICA.csr -signkey /etc/ssl/nginx/$SERVER_FRIENDICA.key -out /etc/ssl/nginx/$SERVER_FRIENDICA.crt 
fi

# Creating friendica virtual host configuration
echo "
# Redirect connections from port 8181 to Tor hidden service friendica port 80
server {
  listen 8181;
  server_name $SERVER_FRIENDICA;
  return 301 http://$SERVER_FRIENDICA;
}

# Redirect connections from 10.0.0.252 to Tor hidden service friendica
server {
        listen 10.0.0.252:80;
        server_name _;
        return 301 http://friendica.librenet;
}
  
# Redirect connections from http to https
#server {
#  listen 10.0.0.252:80;
#  server_name friendica.librenet;
#  
#  index index.php;
#  root /var/www/friendica;
#  rewrite ^ https://friendica.librenet\$request_uri? permanent;
#  }

# Main server for Tor hidden service friendica
server {
  listen 10.0.0.252:80;
  server_name $SERVER_FRIENDICA;

  index index.php;
  root /var/www/friendica;
  rewrite ^ https://$SERVER_FRIENDICA\$request_uri? permanent;
}

# Configure Friendica with SSL

server {
  listen 10.0.0.252:80;
  server_name friendica.librenet;

#  ssl on;
#  ssl_certificate /etc/ssl/nginx/$SERVER_FRIENDICA.crt;
#  ssl_certificate_key /etc/ssl/nginx/$SERVER_FRIENDICA.key;
#  ssl_session_timeout 5m;
#  ssl_protocols SSLv3 TLSv1;
#  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
#  ssl_prefer_server_ciphers on;

  index index.php;
  charset utf-8;
  root /var/www/friendica;
  access_log /var/log/nginx/friendica.log;
  # allow uploads up to 20MB in size
  client_max_body_size 20m;
  client_body_buffer_size 128k;
  # rewrite to front controller as default rule
  location / {
    rewrite ^/(.*) /index.php?q=\$uri&\$args last;
  }

  # make sure webfinger and other well known services aren't blocked
  # by denying dot files and rewrite request to the front controller
  location ^~ /.well-known/ {
    allow all;
    rewrite ^/(.*) /index.php?q=\$uri&\$args last;
  }

  # statically serve these file types when possible
  # otherwise fall back to front controller
  # allow browser to cache them
  # added .htm for advanced source code editor library
  location ~* \.(jpg|jpeg|gif|png|ico|css|js|htm|html|ttf|woff|svg)$ {
    expires 30d;
    try_files \$uri /index.php?q=\$uri&\$args;
  }
  # block these file types
  location ~* \.(tpl|md|tgz|log|out)$ {
    deny all;
  }

  # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
  # or a unix socket
  location ~* \.php$ {
    try_files \$uri =404;

    fastcgi_split_path_info ^(.+\.php)(/.+)$;

    # With php5-cgi alone:
    # fastcgi_pass 127.0.0.1:9000;

    # With php5-fpm:
    fastcgi_pass unix:/var/run/php5-fpm.sock;

    include fastcgi_params;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  }

  # deny access to all dot files
  location ~ /\. {
    deny all;
  }
}

server {
  listen 10.0.0.252:443 ssl;
  server_name $SERVER_FRIENDICA;

  ssl on;
  ssl_certificate /etc/ssl/nginx/$SERVER_FRIENDICA.crt;
  ssl_certificate_key /etc/ssl/nginx/$SERVER_FRIENDICA.key;
  ssl_session_timeout 5m;
  ssl_protocols SSLv3 TLSv1;
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
  ssl_prefer_server_ciphers on;

  index index.php;
  charset utf-8;
  root /var/www/friendica;
  access_log /var/log/nginx/friendica.log;
  # allow uploads up to 20MB in size
  client_max_body_size 20m;
  client_body_buffer_size 128k;
  # rewrite to front controller as default rule
  location / {
    rewrite ^/(.*) /index.php?q=\$uri&\$args last;
  }

  # make sure webfinger and other well known services aren't blocked
  # by denying dot files and rewrite request to the front controller
  location ^~ /.well-known/ {
    allow all;
    rewrite ^/(.*) /index.php?q=\$uri&\$args last;
  }

  # statically serve these file types when possible
  # otherwise fall back to front controller
  # allow browser to cache them
  # added .htm for advanced source code editor library
  location ~* \.(jpg|jpeg|gif|png|ico|css|js|htm|html|ttf|woff|svg)$ {
    expires 30d;
    try_files \$uri /index.php?q=\$uri&\$args;
  }
  # block these file types
  location ~* \.(tpl|md|tgz|log|out)$ {
    deny all;
  }

  # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
  # or a unix socket
  location ~* \.php$ {
    try_files \$uri =404;

    fastcgi_split_path_info ^(.+\.php)(/.+)$;

    # With php5-cgi alone:
    # fastcgi_pass 127.0.0.1:9000;

    # With php5-fpm:
    fastcgi_pass unix:/var/run/php5-fpm.sock;

    include fastcgi_params;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  }

  # deny access to all dot files
  location ~ /\. {
    deny all;
  }
}

" > /etc/nginx/sites-enabled/friendica 


# Configuring Owncloud virtual host
echo "Configuring Owncloud virtual host ..."

# Getting Tor hidden service owncloud hostname
SERVER_OWNCLOUD="$(cat /var/lib/tor/hidden_service/owncloud/hostname 2>/dev/null)"

echo "Generating keys and certificates for Owncloud ..."
rm -rf /etc/ssl/nginx/owncloud.key
rm -rf /etc/ssl/nginx/owncloud.csr
rm -rf /etc/ssl/nginx/owncloud.crt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/nginx/owncloud.key \
	-out /etc/ssl/nginx/owncloud.crt -batch

# Creating Owncloud virtual host configuration
echo "
# Redirect connections from port 7070 to Tor hidden service owncloud port 80
server {
  listen 10.0.0.253:7070;
  server_name $SERVER_OWNCLOUD;
  return 301 https://$SERVER_OWNCLOUD;
}

# Redirect connections from 10.0.0.253 to owncloud with https
server {
        listen 10.0.0.253:80;
        server_name _;
        return 301 https://owncloud.librenet;
}
  
# Redirect connections from owncloud.librenet to Tor hidden service owncloud
server {
  listen 10.0.0.253:443 ssl;
  ssl_certificate      /etc/ssl/nginx/owncloud.crt;
  ssl_certificate_key  /etc/ssl/nginx/owncloud.key;
  server_name owncloud.librenet;
  index index.php;
  root /var/www/owncloud;

  # set max upload size
  client_max_body_size 10G;
  fastcgi_buffers 64 4K;

  # rewrite rules
  rewrite ^/caldav(.*)\$ /remote.php/caldav\$1 redirect;
  rewrite ^/carddav(.*)\$ /remote.php/carddav\$1 redirect;
  rewrite ^/webdav(.*)\$ /remote.php/webdav\$1 redirect;

  # error pages paths
  error_page 403 /core/templates/403.php;
  error_page 404 /core/templates/404.php;

  location ~ \.php(?:\$|/) {
   fastcgi_split_path_info ^(.+\.php)(/.+)\$;
   include fastcgi_params;
   fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
   fastcgi_param PATH_INFO \$fastcgi_path_info;
   fastcgi_param HTTPS on;
   fastcgi_pass unix:/var/run/php5-fpm.sock;
   }


  location = /robots.txt {
    allow all;
    log_not_found off;
    access_log off;
    }

  location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README){
    deny all;
    }

  location / {
   # The following 2 rules are only needed with webfinger
   rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
   rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;

   rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
   rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;

   rewrite ^(/core/doc/[^\/]+/)\$ \$1/index.html;

   try_files \$uri \$uri/ /index.php;
   }

   # Optional: set long EXPIRES header on static assets
   location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|css|js|swf)\$ {
       expires 30d;
       # Optional: Dont log access to assets
         access_log off;
   }

}

# Main server for Tor hidden service owncloud
server {
  listen 10.0.0.253:80;
  server_name $SERVER_OWNCLOUD;
  index index.php;
  root /var/www/owncloud;

  # php5-fpm configuration
  location ~ \.php$ {
  fastcgi_split_path_info ^(.+\.php)(/.+)$;
  fastcgi_pass unix:/var/run/php5-fpm.sock;
  fastcgi_index index.php;
  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  include fastcgi_params;
  }
}
" > /etc/nginx/sites-enabled/owncloud

#  server {
#  listen 80;
#  server_name $SERVER_OWNCLOUD;
#  return 301 https://\$server_name\$request_uri;
#  }
#  
#server {
#  listen 10.0.0.253;
#  server_name _;
#  return 301 https://$SERVER_OWNCLOUD;
#}
#
#server {
#  listen 80;
#  server_name owncloud.librenet;
#  return 301 https://$SERVER_OWNCLOUD\$request_uri;
#  }
#
#server {
#  listen 7070;
#  server_name $SERVER_OWNCLOUD;
#  return 301 https://\$server_name\$request_uri;
#  }
#
#server {
#  listen 443;
#  ssl on;
#  server_name $SERVER_OWNCLOUD;
#  ssl_certificate /etc/ssl/nginx/$SERVER_OWNCLOUD.crt;
#  ssl_certificate_key /etc/ssl/nginx/$SERVER_OWNCLOUD.key;
#
#  # Path to the root of your installation
#  root /var/www/owncloud/;
#  # set max upload size
#  client_max_body_size 10G;
#  fastcgi_buffers 64 4K;
#
#  rewrite ^/caldav(.*)\$ /remote.php/caldav\$1 redirect;
#  rewrite ^/carddav(.*)\$ /remote.php/carddav\$1 redirect;
#  rewrite ^/webdav(.*)\$ /remote.php/webdav\$1 redirect;
#
#  index index.php;
#  error_page 403 /core/templates/403.php;
#  error_page 404 /core/templates/404.php;
#
#  location = /robots.txt {
#    allow all;
#    log_not_found off;
#    access_log off;
#    }
#
#  location ~ ^/(?:\.htaccess|data|config|db_structure\.xml|README){
#    deny all;
#    }
#
#  location / {
#   # The following 2 rules are only needed with webfinger
#   rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
#   rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
#
#   rewrite ^/.well-known/carddav /remote.php/carddav/ redirect;
#   rewrite ^/.well-known/caldav /remote.php/caldav/ redirect;
#
#   rewrite ^(/core/doc/[^\/]+/)\$ \$1/index.html;
#
#   try_files \$uri \$uri/ /index.php;
#   }
#
#   location ~ \.php(?:\$|/) {
#   fastcgi_split_path_info ^(.+\.php)(/.+)\$;
#   include fastcgi_params;
#   fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#   fastcgi_param PATH_INFO \$fastcgi_path_info;
#   fastcgi_param HTTPS on;
#   fastcgi_pass php-handler;
#   }
#
#   # Optional: set long EXPIRES header on static assets
#   location ~* \.(?:jpg|jpeg|gif|bmp|ico|png|css|js|swf)\$ {
#       expires 30d;
#       # Optional: Dont log access to assets
#         access_log off;
#   }
#
#  }
#" > /etc/nginx/sites-enabled/owncloud

# Configuring Mailpile virtual host
echo "Configuring Mailpile virtual host ..."

# Getting Tor hidden service mailpile hostname
SERVER_MAILPILE="$(cat /var/lib/tor/hidden_service/mailpile/hostname 2>/dev/null)"

# Generating certificates for mailpile ssl connection
echo "Generating keys and certificates for MailPile"
if [ ! -e /etc/ssl/nginx/$SERVER_MAILPILE.key -o ! -e  /etc/ssl/nginx/$SERVER_MAILPILE.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/$SERVER_MAILPILE.key -out /etc/ssl/nginx/$SERVER_MAILPILE.crt -batch
fi

# Creating mailpile virtual host configuration
echo "
# Redirect connections from 10.0.0.254 to Tor hidden service mailpile
server {
        listen 10.0.0.254;
        server_name _;
        return 301 http://mailpile.librenet;
}   

# Redirect connections from mailpile.librenet to Tor hidden service mailpile
server {
    # Mailpile Domain
    server_name mailpile.librenet;
    client_max_body_size 20m;

    # Nginx port 80 and 443
    listen 10.0.0.254:80;
    listen 10.0.0.254:443 ssl;

    # SSL Certificate File
    ssl_certificate      /etc/ssl/nginx/$SERVER_MAILPILE.crt;
    ssl_certificate_key  /etc/ssl/nginx/$SERVER_MAILPILE.key;
    # Nginx Poroxy pass for mailpile
    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://127.0.0.1:33411;
        proxy_read_timeout  90;
    }
} 

server {

    # Mailpile Domain
    server_name $SERVER_MAILPILE;
    client_max_body_size 20m;

    # Nginx port 80 and 443
    listen 10.0.0.254:80;
    listen 10.0.0.254:443 ssl;

    # SSL Certificate File
    ssl_certificate      /etc/ssl/nginx/$SERVER_MAILPILE.crt;
    ssl_certificate_key  /etc/ssl/nginx/$SERVER_MAILPILE.key;
    # Nginx Poroxy pass for mailpile
    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://127.0.0.1:33411;
        proxy_read_timeout  90;
    }
}
" > /etc/nginx/sites-enabled/mailpile


# Configuring Webmin virtual host
echo "Configuring Webmin virtual host ..."

# Generating certificates for webmin ssl connection
echo "Generating keys and certificates for webmin"
if [ ! -e /etc/ssl/nginx/webmin.key -o ! -e  /etc/ssl/nginx/webmin.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/webmin.key -out /etc/ssl/nginx/webmin.crt -batch
fi

# Creating Webmin virtual host configuration
echo "
# Redirect connections from 10.0.0.10 to webmin.librenet
server {
        listen 10.0.0.10;
        server_name _;
        return 301 https://webmin.librenet;
}

# Redirect connections to webmin running on 127.0.0.1:10000
server {
        listen 10.0.0.10:443 ssl;
        server_name webmin.librenet;

  ssl on;
  ssl_certificate /etc/ssl/nginx/webmin.crt;
  ssl_certificate_key /etc/ssl/nginx/webmin.key;
  ssl_session_timeout 5m;
  ssl_protocols SSLv3 TLSv1;
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
  ssl_prefer_server_ciphers on;

location / {
    proxy_pass       https://127.0.0.1:10000;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }

}
" > /etc/nginx/sites-enabled/webmin

# Configuring Kibana virtual host
echo "Configuring Kibana virtual host ..."

# Generating certificates for Kibana ssl connection
echo "Generating keys and certificates for Kibana"
if [ ! -e /etc/ssl/nginx/kibana.key -o ! -e  /etc/ssl/nginx/kibana.crt ]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/nginx/kibana.key -out /etc/ssl/nginx/kibana.crt -batch
fi

# Creating Kibana virtual host configuration
echo '
server {
	listen 10.0.0.11;
	server_name _;
	return 301 https://kibana.librenet;
	}

server {
	listen 80;
	listen 443 ssl;
	server_name kibana.librenet;

	ssl on;
	ssl_certificate /etc/ssl/nginx/kibana.crt;
	ssl_certificate_key /etc/ssl/nginx/kibana.key;
	ssl_session_timeout 5m;
	ssl_protocols SSLv3 TLSv1;
	ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
	ssl_prefer_server_ciphers on;
	access_log /var/log/nginx/kibana.access.log;
	error_log /var/log/nginx/kibana.error.log;

	location / {
		proxy_pass       http://127.0.0.1:5601;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;
	}
}
' > /etc/nginx/sites-enabled/kibana

# Configuring Snorby virtual host
echo "Configuring Snorby virtual host ..."
echo '
server {
	listen 10.0.0.12:80;
	server_name snorby.librenet;
	passenger_enabled on;
	passenger_ruby /usr/bin/ruby2.1;
	passenger_user  root;
	passenger_group root;

	access_log /var/log/nginx/snorby.log;
	root /var/www/snorby/public;
	index index.html;
	
	location /snorby {
		root /usr/www/snorby/public;
		index index.html;
		location ~ \.cgi$ {
			try_files $uri =404;
			include fastcgi_params;
			fastcgi_pass unix:/var/run/fcgiwrap/fcgiwrap.sock;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			fastcgi_param REMOTE_USER $remote_user;
		}

		location ~ \.php$ {
			try_files $uri =404;
			include fastcgi_params;
			fastcgi_pass 127.0.0.1:9000;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		}
	}
}
' > /etc/nginx/sites-enabled/snorby

# Configuring squidguard virtual host
echo "Configuring squidguard virtual host ..."
echo '
# Redirect connections from 10.0.0.13 to squidguardmgr.librenet
server {
        listen 10.0.0.13:80;
        server_name _;
        return 301 http://squidguard.librenet;
}

server {
  listen 10.0.0.13:80;
  server_name squidguard.librenet;

  index squidguardmgr.cgi;
  charset utf-8;
  root /var/www/squidguardmgr;
  access_log /var/log/nginx/squidguardmgr.log;

  location ~ .cgi\$ {
    include uwsgi_params;
    uwsgi_modifier1 9;
    uwsgi_pass 127.0.0.1:9000;
  }
}
' > /etc/nginx/sites-enabled/squidguard

# Include passenger in nginx
sed -i -e 's@\t# include /etc/nginx/passenger.conf.*@\tinclude /etc/nginx/passenger.conf;@g' /etc/nginx/nginx.conf

# Configuring EasyRTC virtual host
echo "Configuring EasyRTC virtual host ..."

# Getting Tor hidden service EasyRTC hostname
SERVER_EASYRTC="$(cat /var/lib/tor/hidden_service/easyrtc/hostname 2>/dev/null)"

# Generating keys and certificates for https connection
echo "Generating keys and certificates for Owncloud ..."
rm -rf /etc/ssl/nginx/easyrtc.key
rm -rf /etc/ssl/nginx/easyrtc.csr
rm -rf /etc/ssl/nginx/easyrtc.crt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/nginx/easyrtc.key \
        -out /etc/ssl/nginx/easyrtc.crt -batch

# Creating EasyRTC virtual host configuration
echo "
# Redirect connections from 10.0.0.250 to EasyTRC https 
server {
        listen 10.0.0.250;
        server_name _;
        return 301 https://easyrtc.librenet/demos/;
}

# easyrtc https server 
server {
        listen 10.0.0.250:443 ssl;
        server_name easyrtc.librenet;
        ssl_certificate /etc/ssl/nginx/easyrtc.crt;
        ssl_certificate_key /etc/ssl/nginx/easyrtc.key;
  location / {
    proxy_pass       https://127.0.0.1:8443;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}

server {
        listen 10.0.0.250:443 ssl;
        server_name $SERVER_EASYRTC;
        ssl_certificate /etc/ssl/nginx/easyrtc.crt;
        ssl_certificate_key /etc/ssl/nginx/easyrtc.key;
  location / {
    proxy_pass       https://127.0.0.1:8443;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
" > /etc/nginx/sites-enabled/easyrtc

# i2p.librenet virtual host configuration  

echo "
server {
        listen 10.0.0.1:80;
        server_name i2p.librenet;

location / {
    proxy_pass       http://127.0.0.1:7657;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
" > /etc/nginx/sites-enabled/i2p 

# tahoe.librenet virtual host configuration

echo "
server {
        listen 10.0.0.1:80;
        server_name tahoe.librenet;

location / {
    proxy_pass       http://127.0.0.1:3456;
    proxy_set_header Host      \$host;
    proxy_set_header X-Real-IP \$remote_addr;
  }
}
" > /etc/nginx/sites-enabled/tahoe

# Restarting Yacy php5-fpm and Nginx services 
echo "Restarting nginx ..."
service yacy restart
service php5-fpm restart
service nginx restart
}

# ---------------------------------------------------------
# Function to check interfaces
# ---------------------------------------------------------
check_interfaces()
{
# Preparing script file
rm -rf /root/libre_scripts/
mkdir /root/libre_scripts/
touch /root/libre_scripts/check_interfaces.sh
chmod +x /root/libre_scripts/check_interfaces.sh


# Script to check interfaces
cat << EOF > /root/libre_scripts/check_interfaces.sh
#!/bin/bash
# Checking physical interfaces (eth0 and eth1)
if ip addr show eth1 | grep 'state UP'; then
    if ip addr show eth0 | grep 'state UP'; then
        # Checking virtual interfaces (ethx:1 ethx:2 ethx:3 ethx:4 ethx:5 ethx:6)
            if ping -c 1 10.0.0.10; then
                if ping -c 1 10.0.0.250; then
                    if ping -c 1 10.0.0.251; then
                        if ping -c 1 10.0.0.252; then
                            if ping -c 1 10.0.0.253; then
                                if ping -c 1 10.0.0.254; then
                                    logger "Check Interfaces: Network is ok"
                                else
                                    #Make a note in syslog
                                    logger "Check Interfaces: ethx:4 is down, restarting network ..."
                                    /etc/init.d/networking restart
                                    exit
                                fi
                            else
                                #Make a note in syslog
                                logger "Check Interfaces: ethx:3 is down, restarting network ..."
                                /etc/init.d/networking restart
                                exit
                            fi
                        else
                            #Make a note in syslog
                            logger "Check Interfaces: ethx:2 is down, restarting network ..."
                            /etc/init.d/networking restart
                            exit
                        fi
                    else
                        #Make a note in syslog
                        logger "Check Interfaces: ethx:1 is down, restarting network ..."
                        /etc/init.d/networking restart
                        exit
                    fi
                else
                    #Make a note in syslog
                    logger "Check Interfaces: ethx:6 is down, restarting network ..."
                    /etc/init.d/networking restart
                    exit
                fi
            else
                #Make a note in syslog
                logger "Check Interfaces: ethx:5 is down, restarting network ..."
                /etc/init.d/networking restart
                exit
            fi
    else
        #Make a note in syslog
        logger "Check Interfaces: eth0 is down, restarting network ..."
        /etc/init.d/networking restart
        exit
    fi
else
    #Make a note in syslog
    logger "Check Interfaces: eth1 is down, restarting network ..."
    /etc/init.d/networking restart
    exit
fi
EOF


# Creating cron job
rm -rf /root/libre_scripts/cron_jobs
echo "@reboot sleep 20 && /root/libre_scripts/check_interfaces.sh" > /root/libre_scripts/cron_jobs
crontab /root/libre_scripts/cron_jobs
}


# ---------------------------------------------------------
# Function to check services
# ---------------------------------------------------------
check_services()
{
# Preparing script file
rm -rf /root/libre_scripts/check_services.sh
touch /root/libre_scripts/check_services.sh
chmod +x /root/libre_scripts/check_services.sh


# Script to check services
cat << EOF > /root/libre_scripts/check_services.sh
#!/bin/bash
# Checking unbound
if /etc/init.d/unbound status | grep "active (running)"; then
    logger "Check Services: Unbound is ok"
else
    logger "Check Services: Unbound is not running. Restarting ..."
    /etc/init.d/unbound restart
fi

# Checking isc-dhcp-server
if /etc/init.d/isc-dhcp-server status | grep "active (running)"; then
    logger "Check Services: isc-dhcp-server is ok"
else
    logger "Check Services: isc-dhcp-server is not running. Restarting ..."
    /etc/init.d/isc-dhcp-server restart
fi

# Checking squid
if /etc/init.d/squid status | grep "active (running)"; then
    logger "Check Services: squid is ok"
else
    logger "Check Services: squid is not running. Restarting ..."
    /etc/init.d/squid restart
fi

# Checking squid-tor
if /etc/init.d/squid-tor status | grep "active (running)"; then
    logger "Check Services: squid-tor is ok"
else
    logger "Check Services: squid-tor is not running. Restarting ..."
    /etc/init.d/squid-tor restart
fi

# Checking squid-i2p
if /etc/init.d/squid-i2p status | grep "active (running)"; then
    logger "Check Services: squid-i2p is ok"
else
    logger "Check Services: squid-i2p is not running. Restarting ..."
    /etc/init.d/squid-i2p restart
fi

# Checking clamav-daemon
if /etc/init.d/clamav-daemon status | grep "active (running)"; then
    logger "Check Services: clamav-daemon is ok"
else
    logger "Check Services: clamav-daemon is not running. Restarting ..."
    /etc/init.d/clamav-daemon restart
fi

# Checking c-icap
if /etc/init.d/c-icap status | grep "active (running)"; then
    logger "Check Services: c-icap is ok"
else
    logger "Check Services: c-icap is not running. Restarting ..."
    /etc/init.d/c-icap restart
fi

# Checking privoxy
if /etc/init.d/privoxy status | grep "active (running)"; then
    logger "Check Services: privoxy is ok"
else
    logger "Check Services: privoxy is not running. Restarting ..."
    /etc/init.d/privoxy restart
fi

# Checking privoxy-tor
if /etc/init.d/privoxy-tor status | grep "active (running)"; then
    logger "Check Services: privoxy-tor is ok"
else
    logger "Check Services: privoxy-tor is not running. Restarting ..."
    /etc/init.d/privoxy-tor restart
fi

# Checking nginx
if /etc/init.d/nginx status | grep "active (running)"; then
    logger "Check Services: Nginx is ok"
else
    logger "Check Services: Nginx is not running. Restarting ..."
    /etc/init.d/nginx restart
fi
EOF


# Creating cron job
echo "@reboot sleep 40 && /root/libre_scripts/check_interfaces.sh" >> /root/libre_scripts/cron_jobs
crontab /root/libre_scripts/cron_jobs
}


# ---------------------------------------------------------
# Function to configure Suricata service
# ---------------------------------------------------------
configure_suricata()
{
	echo "Configuring Suricata ..."

	# Suricata configuration
	sed -i -e '/#HOME_NET:/d' /etc/suricata/suricata.yaml
	sed -i -e 's@HOME_NET:.*$@HOME_NET: "[10.0.0.0/24]"@g' /etc/suricata/suricata.yaml
	sed -i -e 's@  windows: \[.*\]@  windows: []@g' /etc/suricata/suricata.yaml
	sed -i -e 's@  linux: \[.*\]@  linux: [0.0.0.0]@g' /etc/suricata/suricata.yaml
	sed -i -e "s@  - interface: eth0@  - interface: $INT_INTERFACE@g" /etc/suricata/suricata.yaml

	# Suricata logs
	touch /var/log/suricata/eve.json
	touch /var/log/suricata/fast.log
	touch /var/log/suricata/stats.log
	touch /var/log/suricata/suricata.log
	chmod 644 /var/log/suricata/*.log

	# Suricata service
	cat << EOF > /etc/default/suricata
# Default config for Suricata

# set to yes to start the server in the init.d script
RUN=yes

# Configuration file to load
SURCONF=/etc/suricata/suricata.yaml

# Listen mode: pcap, nfqueue or af-packet
# depending on this value, only one of the two following options
# will be used (af-packet uses neither).
# Please note that IPS mode is only available when using nfqueue
LISTENMODE=af-packet

# Interface to listen on (for pcap mode)
IFACE=$INT_INTERFACE

# Queue number to listen on (for nfqueue mode)
NFQUEUE=0

# Pid file
PIDFILE=/var/run/suricata.pid
EOF
	echo "Restarting suricata ..."
	update-rc.d suricata defaults
	service suricata restart
}


# ---------------------------------------------------------
# Function to configure Kibana
# ---------------------------------------------------------
configure_kibana()
{
        echo "Configuring Kibana ..."

	# Configure PAM limits
	sed -i -e '/# End of file/d' /etc/security/limits.conf
	echo 'elasticsearch hard memlock 102400' >> /etc/security/limits.conf
	echo '# End of file' >> /etc/security/limits.conf
	# Configure elastic
	cat << EOF > /etc/default/elasticsearch
################################
# Elasticsearch
################################

ES_JAVA_OPTS="Des.insecure.allow.root=true"

# Elasticsearch home directory
ES_HOME=/usr/share/elasticsearch

# Elasticsearch configuration directory
CONF_DIR=/etc/elasticsearch

# Elasticsearch data directory
DATA_DIR=/var/lib/elasticsearch

# Elasticsearch logs directory
LOG_DIR=/var/log/elasticsearch

# Elasticsearch PID directory
PID_DIR=/var/run/elasticsearch

# Memory usage
ES_HEAP_SIZE=128m
MAX_LOCKED_MEMORY=102400
ES_JAVA_OPTS=-server

# The number of seconds to wait before checking if Elasticsearch started successfully as a daemon process
ES_STARTUP_SLEEP_TIME=15
EOF
	# Fix logstash permissions
	sed -i -e 's/LS_GROUP=.*/LS_GROUP=root/g' /etc/init.d/logstash
	systemctl daemon-reload

	# Enable autostart
	systemctl enable elasticsearch
	echo "Restarting elasticsearch ..."
	service elasticsearch restart
	systemctl enable kibana
	systemctl enable logstash

	echo "Restarting logstash ..."
	service logstash restart
	echo "Applying Kibana dashboards ..."
	sleep 20 && /opt/KTS/load.sh && echo ""
	echo "Kibana dashboards were successfully configured"
	echo "Restarting kibana ..."
	service kibana restart
}


configure_snortbarn()
{
	echo "Configuring Snort + Barnyard2"

	# Configure Snort
	sed -i -e 's@ipvar HOME_NET .*@ipvar HOME_NET 10.0.0.0/24@g' /etc/snort/snort.conf
	sed -i -e 's@ipvar EXTERNAL_NET .*@ipvar EXTERNAL_NET any@g' /etc/snort/snort.conf
	echo 'output unified2: filename snort.log, limit 128' >> /etc/snort/snort.conf
	sed -i -e 's@# alert@alert@g' /etc/snort/rules/snort.rules

	# Validate Snort configuration
	snort -T -i $INT_INTERFACE -c /etc/snort/snort.conf
	if [ $? -ne 0 ]; then
		echo "Error: invalid Snort configuration"
		exit 1
	fi

	# Configure Barnyard
	sed -i -e 's/#config hostname:.*/config hostname: librerouter/g' /etc/snort/barnyard2.conf
	sed -i -e "s/#config interface:.*/config interface: $INT_INTERFACE/g" /etc/snort/barnyard2.conf
	echo "output database: log, mysql, user=root password=$MYSQL_PASS dbname=snorby host=localhost" >> /etc/snort/barnyard2.conf
	touch /var/log/snort/barnyard2.waldo

	# Create startup scripts
	cat << EOF > /etc/init.d/snortbarn
#!/bin/sh
#
### BEGIN INIT INFO
#Provides: snortbarn
#Required-Start: \$remote_fs \$syslog mysql
#Required-Stop: \$remote_fs \$syslog
#Default-Start: 2 3 4 5
#Default-Stop: 0 1 6
#X-Interactive: true
#Short-Description: Start Snort and Barnyard
### END INIT INFO

. /lib/init/vars.sh
. /lib/lsb/init-functions

mysqld_get_param() {
/usr/sbin/mysqld --print-defaults | tr " " "\n" | grep -- "--\$1" | tail -n 1 | cut -d= -f2
}

do_start()
{
    log_daemon_msg "Starting Snort and Barnyard" ""
    # Make sure mysql has finished starting
    ps_alive=0
    while [ \$ps_alive -lt 1 ];
    do
    pidfile=\`mysqld_get_param pid-file\`
    if [ -f "\$pidfile" ] && ps \`cat \$pidfile\` >/dev/null 2>&1; then ps_alive=1; fi
	sleep 1
    done

    /usr/bin/snort -q -i $INT_INTERFACE -c /etc/snort/snort.conf -D
    /usr/bin/barnyard2 -q -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.log -w /var/log/snort/barnyard2.waldo -D

    log_end_msg 0
    return 0
}

do_stop()
{
    log_daemon_msg "Stopping Snort and Barnyard" ""
    kill \$(pidof snort) 2> /dev/null
    kill \$(pidof barnyard2) 2> /dev/null
    log_end_msg 0
    return 0
}

case "\$1" in
 start)
    do_start
    ;;
 stop)
    do_stop
    ;;
 restart)
    do_stop
    do_start
    ;;
 *)
    echo "Usage: snort-barn {start|stop|restart}" >&2
    exit 3
    ;;
esac
exit 0
EOF
	chmod +x /etc/init.d/snortbarn
	update-rc.d snortbarn defaults
	insserv -f -v snortbarn
	service snortbarn start

	# Create cron job for pulledpork
	echo '10 1 * * * root /usr/sbin/pulledpork.pl -c /etc/snort/pulledpork.conf' >> /etc/crontab
	echo '25 1 * * * root service snortbarn restart' >> /etc/crontab
}


configure_snorby()
{
	echo "Configuring Snorby"
	cat << EOF > /var/www/snorby/config/snorby_config.yml
production:
  domain: 'snorbi.librenet'
  wkhtmltopdf: /usr/bin/wkhtmltopdf
  ssl: false
  mailer_sender: 'snorby@example.com'
  geoip_uri: "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
  rules:
    - "/etc/snort/rules"
  authentication_mode: database
  timezone_search: true
EOF

	cat << EOF > /var/www/snorby/config/database.yml
# Snorby Database Configuration
snorby: &snorby
  adapter: mysql
  username: root
  password: "$MYSQL_PASS"
  host: localhost

production:
  database: snorby
  <<: *snorby
EOF
	cd /var/www/snorby
	RAILS_ENV=production bundle exec rake snorby:setup
	cd
	mysql -u root --password=$MYSQL_PASS -e "grant all on snorby.* to root@localhost"
	mysql -u root --password=$MYSQL_PASS -e "flush privileges"
	# Create startup script
	cat << EOF > /etc/init.d/snorby
#!/bin/sh
#
### BEGIN INIT INFO
#Provides: snorby
#Required-Start: \$remote_fs \$syslog mysql
#Required-Stop: \$remote_fs \$syslog
#Default-Start: 2 3 4 5
#Default-Stop: 0 1 6
#X-Interactive: true
#Short-Description: Restart Snorby worker
### END INIT INFO

. /lib/init/vars.sh
. /lib/lsb/init-functions

do_start()
{
    log_daemon_msg "Starting Snorby worker" ""
    cd /var/www/snorby
    RAILS_ENV=production bundle exec rails r Snorby::Worker.start
    log_end_msg 0
    return 0
}

do_stop()
{
    log_daemon_msg "Stopping Snorby worker" ""
    cd /var/www/snorby
    RAILS_ENV=production bundle exec rails r Snorby::Worker.stop
    log_end_msg 0
    return 0
}

case "\$1" in
 start)
    do_start
    ;;
 stop)
    do_stop
    ;;
 restart)
    do_stop
    do_start
    ;;
 *)
    echo "Usage: snorby {start|stop|restart}" >&2
    exit 3
    ;;
esac
exit 0
EOF
	chmod +x /etc/init.d/snorby
	update-rc.d snorby defaults
	insserv -f -v snorby
	service snorby restart
	service snortbarn restart
}


# ---------------------------------------------------------
# Function to print info about services accessibility
# ---------------------------------------------------------
print_services()
{
touch /var/box_services
echo "Printing local services info ..."
echo ""
echo "------------------------------------------------------------------------------" \
| tee /var/box_services
echo "| Service Name |       Tor domain       |    Direct access    |  IP Address  |" \
| tee -a /var/box_services
echo "------------------------------------------------------------------------------" \
| tee -a /var/box_services
for i in $(ls /var/lib/tor/hidden_service/)
 do
    if [ $i == "easyrtc" ]; then
      IP_ADD="10.0.0.250"
    fi
    if [ $i == "yacy" ]; then
      IP_ADD="10.0.0.251"
    fi
    if [ $i == "friendica" ]; then
      IP_ADD="10.0.0.252"
    fi
    if [ $i == "owncloud" ]; then
      IP_ADD="10.0.0.253"
    fi
    if [ $i == "mailpile" ]; then
      IP_ADD="10.0.0.254"
    fi
    hn="$(cat /var/lib/tor/hidden_service/$i/hostname 2>/dev/null )"
    printf "|%12s  |%23s |%11s.librenet |%13s |\n" $i $hn $i $IP_ADD \
    | tee -a /var/box_services
 done
echo "------------------------------------------------------------------------------" \
| tee -a /var/box_services
}
	

# ---------------------------------------------------------
# ************************ MAIN ***************************
# This is the main function on this script
# ---------------------------------------------------------

# Block 1: Configuing Network Interfaces

check_root			# Checking user
get_variables			# Getting variables
configure_hosts			# Configurint hostname and /etc/hosts
configure_interfaces		# Configuring external and internal interfaces
configure_dhcp			# Configuring DHCP server 


# Block 2: Configuring services

configure_mysql			# Configuring mysql password
configure_banks_access		# Configuring banks access
configure_iptables		# Configuring iptables rules
configure_tor			# Configuring TOR server
configure_i2p			# Configuring i2p services
configure_unbound		# Configuring Unbound DNS server
configure_friendica		# Configuring Friendica local service
configure_easyrtc		# Configuring EasyRTC local service
configure_owncloud		# Configuring Owncloud local service
configure_mailpile		# Configuring Mailpile local service
configure_nginx                 # Configuring Nginx web server
configure_privoxy		# Configuring Privoxy proxy server
configure_squid			# Configuring squid proxy server
configure_c_icap		# Configuring c-icap daemon
configure_squidclamav		# Configuring squidclamav service
configure_squidguard		# Configuring squidguard
configure_squidguardmgr		# Configure squidguardmgr
configure_e2guardian		# Configuring e2guardian
configure_postfix		# Configuring postfix mail service
check_interfaces		# Checking network interfaces
check_services			# Checking services 
configure_suricata		# Configure Suricata service
configure_kibana		# Configure Kibana service
configure_snortbarn		# Configure Snort and Barnyard services
configure_snorby		# Configure Snorby
print_services			# Print info about service accessibility

#configure_blacklists		# Configuring blacklist to block some ip addresses


