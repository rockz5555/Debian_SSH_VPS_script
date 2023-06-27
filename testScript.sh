#!/bin/bash
# ***********************************************
#       Simple Script to setup Debian VPS       *
# This Script only setup SSH,SSl,Dropbear,squid *
#        Script by : Tharuka Sandaruwan         *
# ***********************************************
#
clear 
echo -e "
\e[34;1m   __      __       .__                             ._.  \e[0m
\e[34;1m  /  \    /  \ ____ |  |   ____  ____   _____   ____| |  \e[0m
\e[34;1m  \   \/\/   // __ \|  | _/ ___\/  _ \ /     \_/ __ \ |  \e[0m
\e[34;1m   \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/\|  \e[0m
\e[34;1m    \__/\  /  \___  >____/\___  >____/|__|_|  /\___ >_  \e[0m
\e[34;1m         \/       \/          \/            \/     \/\/  \e[0m
\e[31;1m        VPS AUTOSCRIPT BY THARUKA SANDARUWAN              \e[0m";

read -n1 -r -p "Press Any Key To Setup Your VPS....        "
clear

#getting things ready
apt-get update
apt-get upgrade -y
clear

# downloading menu
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/main/files/menu"
chmod +x /usr/local/bin/menu

#setting the time zone to Sri Lankan (GTM +0530) 
ln -fs /usr/share/zoneinfo/Asia/Colombo /etc/localtime;
clear

#enabling ip4 and ipv6
apt-get install -y gnupg2 gnupg gnupg1
echo ipv4 >> /etc/modules
echo ipv6 >> /etc/modules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sysctl -p
clear

#purging packages
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove postfix*;
apt-get -y --purge remove bind*;
apt-get -y remove unscd*;
clear



#getting required libraries
apt-get -y autoremove;
apt-get -y install wget curl;
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-transport-https apt-show-versions python unzip -y
clear


# ssh
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
wget -O /etc/issue.net "https://raw.githubusercontent.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/main/files/issue.net"


# dropbear
apt-get -y install dropbear
wget -O /etc/default/dropbear "https://raw.githubusercontent.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/main/files/dropbear"
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart

#getting ip info and setting them
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;


# squid3
apt-get -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/main/files/squid.conf"
sed -i "s/ipserver/$myip/g" /etc/squid/squid.conf

# Setting Server
wget -O /etc/rc.local "https://raw.githubusercontent.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/main/files/rc.local"
chmod +x /etc/rc.local

#getting things ready to compile badvpn
apt-get update >/dev/null 2>/dev/null
apt-get install -y nano >/dev/null 2>/dev/null
apt-get install -y sudo >/dev/null 2>/dev/null
apt-get install -y gcc >/dev/null 2>/dev/null
apt-get install -y make >/dev/null 2>/dev/null
apt-get install -y g++ >/dev/null 2>/dev/null
apt-get install -y openssl >/dev/null 2>/dev/null
apt-get install -y build-essential >/dev/null 2>/dev/null
apt-get install -y cmake >/dev/null 2>/dev/null

# compiling and installing badvpn
apt-get install cmake -y
apt-get install screen wget gcc build-essential g++ make -y
wgethttps://github.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/raw/main/badvpn/badvpn-1.999.128.tar.bz2
tar xf badvpn-1.999.128.tar.bz2
cd badvpn-1.999.128/
cmake ~/badvpn-1.999.128 -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
make install
echo "paleistas BadVPN portu 7300"
badvpn-udpgw --listen-addr 127.0.0.1:7300 > /dev/null &
rm /root/badupd
echo "Badupd sekmingai irasytas!!"
echo "Buk_laisvas HS_pro 2019"

# Stunnel installing
apt-get install stunnel4 -y
wget -P /etc/stunnel/ "https://raw.githubusercontent.com/Tharuka-Sandaruwan/Debian_SSH_VPS_script/main/files/stunnel.conf"
 # Creating stunnel certifcate using openssl
openssl req -new -x509 -days 9999 -nodes -subj "/C=US/ST=SBH/L=TWU/O=THARUKA/OU=SANDARUWAN/CN=THARUKA" -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &> /dev/null
##  > /dev/null 2>&1
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

# Allowing ALL TCP ports for VPS (Simple workaround for policy-based VPS)
#iptables -A INPUT -s $(wget -4qO- http://ipinfo.io/ip) -p tcp -m multiport --dport 1:65535 -j ACCEPT


#cleaning unnecessary items
rm *.txt;rm *.tar.gz;rm *.deb;rm *.asc;rm *.zip;rm ddos*;


#speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest

#installing htop
sudo apt-get install htop 
clear


read -n1 -r -p "    Setting up the VPS is complete! Press Any Key To Reboot....        "
reboot
