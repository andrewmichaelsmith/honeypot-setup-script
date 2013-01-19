#!/bin/bash

#user iface choice
sudo apt-get -y install python-pip
sudo pip install netifaces
wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/scripts/iface-choice.py -O /tmp/iface-choice.py
python /tmp/iface-choice.py
iface=$(<~/.honey_iface)


# Move SSH server from Port 22 to Port 66534
sed -i 's:Port 22:Port 65534:g' /etc/ssh/sshd_config
service ssh reload

# update apt repositories
sudo apt-get update

## install p0f ##

sudo apt-get install -y p0f
sudo mkdir /var/p0f/

# dependency for add-apt-repository
sudo apt-get install -y python-software-properties

## install dionaea ##

#add dionaea repo
sudo add-apt-repository -y ppa:honeynet/nightly
sudo apt-get update
sudo apt-get install -y dionaea

#make directories
sudo mkdir -p /var/dionaea/wwwroot
sudo mkdir -p /var/dionaea/binaries
sudo mkdir -p /var/dionaea/log
sudo chown -R nobody:nogroup /var/dionaea/

#edit config
sudo mv /etc/dionaea/dionaea.conf.dist /etc/dionaea/dionaea.conf
sudo sed -i 's/var\/dionaea\///g' /etc/dionaea/dionaea.conf
sudo sed -i 's/log\//\/var\/dionaea\/log\//g' /etc/dionaea/dionaea.conf
sudo sed -i 's:levels = "all":levels = "warning,error":g' /etc/dionaea/dionaea.conf
sudo sed -i "s:eth0:$iface:g" /etc/dionaea/dionaea.conf

#enable p0f
sudo sed -i 's://\s\s*"p0f",:"p0f",:g'  /etc/dionaea/dionaea.conf

## install kippo - we want the latest so we have to grab the source ##

#kippo dependencies
sudo apt-get install -y subversion python-dev openssl python-openssl python-pyasn1 python-twisted iptables

#install kippo to /opt/kippo
sudo mkdir /opt/kippo/
sudo svn checkout http://kippo.googlecode.com/svn/trunk/ /opt/kippo/
sudo mv /opt/kippo/kippo.cfg.dist /opt/kippo/kippo.cfg

#add kippo user that can't login
sudo useradd -r -s /bin/false kippo


#set up log dirs
sudo mkdir -p /var/kippo/dl
sudo mkdir -p /var/kippo/log/tty

#delete old dirs to prevent confusion
sudo rm -rf /opt/kippo/dl
sudo rm -rf /opt/kippo/log

sudo sed -i 's:log_path = log:log_path = /var/kippo/log:g' /opt/kippo/kippo.cfg
sudo sed -i 's:download_path = dl:download_path = /var/kippo/dl:g' /opt/kippo/kippo.cfg


#set up permissions
sudo chown -R kippo:kippo /opt/kippo/
sudo chown -R kippo:kippo /var/kippo/

#start kippo
sudo -u kippo sh start.sh

#point port 22 at port 2222 

sudo iptables -i $iface -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

#persist iptables config
sudo iptables-save > /etc/iptables.rules

#setup iptables restore script
sudo echo '#!/bin/sh' >> /etc/network/if-up.d/iptablesload 
sudo echo 'iptables-restore < /etc/iptables.rules' >> /etc/network/if-up.d/iptablesload 
sudo echo 'exit 0' >> /etc/network/if-up.d/iptablesload 
#enable restore script
sudo chmod +x /etc/network/if-up.d/iptablesload 

#download init files and install them
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/init/p0f -O /etc/init.d/p0f
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/init/dionaea -O /etc/init.d/dionaea
sudo wget https://raw.github.com/andrewmichaelsmith/honeypot-setup-script/master/init/kippo -O /etc/init.d/kippo

#install system services
sudo chmod +x /etc/init.d/p0f
sudo chmod +x /etc/init.d/dionaea
sudo chmod +x /etc/init.d/kippo

sudo update-rc.d p0f defaults
sudo update-rc.d dionaea defaults
sudo update-rc.d kippo defaults

#start the honeypot software
sudo /etc/init.d/kippo start
sudo /etc/init.d/p0f start
sudo /etc/init.d/dionaea start

