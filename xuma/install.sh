#!/bin/bash

clear

cd ~
echo "***********************************************************"
echo "* Welcome to Kayroons XUMA masternode install script      *"
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
sudo apt-get install nano htop git -y
sudo apt-get install build-essential libtool autotools-dev automake unzip pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install qt5-default qttools5-dev-tools libgmp3-dev libzmq3-dev libssl-dev  -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install -y git python-virtualenv

echo && echo "${bold}Installing UFW...${regular}"
sleep 3
sudo apt-get -y install ufw
echo && echo "${bold}Configuring UFW...${regular}"
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 19777/tcp
echo "y" | sudo ufw enable
echo && echo "${bold}Firewall installed and enabled!${regular}"

echo && echo
echo "${bold}Downloading and installing ABSOULTE Files${regular}"
wget https://github.com/xumacoin/xuma-core/releases/download/1.0.5/Xuma-Core-Linux64-1.0.5.zip
unzip Xuma-Core-Linux64-1.0.5.zip
rm Xuma-Core-Linux64-1.0.5.zip
sudo cp Xuma-Core-Linux64-1.0.5/xuma{d,-cli} /usr/local/bin

sleep 3
echo && echo "${bold}Setting config${regular}"
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
IP_ADD=`curl ipinfo.io/ip`
mkdir -p .xuma
mkdir -p .xuma/mainnet
sudo touch .xuma/mainnet/xuma.conf
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
' | sudo -E tee /root/.xuma/mainnet/xuma.conf
sleep 3
echo && echo "${bold}Starting XUMA Deamon...${regular}"
xuma-cli stop
sleep 10
xumad -deamon &
sleep 3
echo && echo "${bold}Checking XUMA Deamon...${regular}"
xuma-cli getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"
