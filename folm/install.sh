#!/bin/bash

clear

cd ~
echo "***********************************************************"
echo "* Welcome to Kayroons FOLM masternode install script      *"
echo "*                                                         *"                                                        
echo "*                   Powered by Kayroons                   *"                                
echo "***********************************************************"
sleep 3
bold=$(tput bold)
regular=$(tput sgr0)
read -e -p "Masternode Private Key (e.g. abcdefghijklmnopqrstuvqxyz1234567890abcde1234567890) : " key
if [[ "$key" == "" ]]; then
    echo "SHIT: You forgot to create a private key? Try to create one in your cold wallet, exiting!!!"
    echo && exit
fi

echo && echo && echo
echo "${bold}Adding swap space${regular}"
sudo touch /var/swap.img
sudo chmod 600 /var/swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
mkswap /var/swap.img
sudo swapon /var/swap.img
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab

sleep 3
echo && echo "${bold}Updating and installing system dependecies${regular}"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get install nano htop git unzip -y
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install qt5-default qttools5-dev-tools libgmp3-dev libzmq3-dev libssl-dev  -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install -y git python-virtualenv

sleep 3
echo && echo "${bold}Installing required boost${regular}"
wget kroapps.com/boost_1_58_0.tar.bz2
tar --bzip2 -xf boost_1_58_0.tar.bz2 
cd boost_1_58_0/
./bootstrap.sh --prefix=/usr/local
./b2 --with=all install
sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf'
ldconfig

echo && echo "${bold}Installing UFW...${regular}"
sleep 3
sudo apt-get -y install ufw
echo && echo "${bold}Configuring UFW...${regular}"
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 53656/tcp
echo "y" | sudo ufw enable
echo && echo "${bold}Firewall installed and enabled!${regular}"

echo && echo
echo "${bold}Downloading and installing FOLM Files${regular}"
wget https://github.com/folm/folm/releases/download/v3.1.1/folm-3.1.1.ubuntu.16.04.zip
unzip folm-3.1.1.ubuntu.16.04.zip
rm folm-3.1.1.ubuntu.16.04.zip
sudo cp folm/folm{d,-cli} /usr/local/bin

sleep 3
echo && echo "${bold}Setting config${regular}"
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
IP_ADD=`curl ipinfo.io/ip`
mkdir -p .folm
sudo touch .folm/folm.conf
echo '
rpcuser='$rpcuser'
rpcpassword='$rpcpassword'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=250
externalip='$IP_ADD'
masternodeprivkey='$key'
masternode=1
' | sudo -E tee /root/.folm/folm.conf
sleep 3
echo && echo "${bold}Starting FOLM Deamon...${regular}"
folm-cli stop
sleep 10
folmd -deamon &
sleep 3

echo && echo "${bold}Checking FOLM Deamon...${regular}"
folm-cli getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"
