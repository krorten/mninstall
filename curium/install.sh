#!/bin/bash

clear

cd ~
echo "***********************************************************"
echo "* Welcome to Kayroons CURIUM masternode install script 	*"
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
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common -y
sudo apt-get install libboost-all-dev -y
sudo apt-get install qt5-default qttools5-dev-tools libgmp3-dev libzmq3-dev libssl-dev  -y
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install -y git python-virtualenv

sleep 3
echo && echo "${bold}Installing core dependecies${regular}"
wget https://github.com/zeromq/libzmq/releases/download/v4.2.2/zeromq-4.2.2.tar.gz
tar xvzf zeromq-4.2.2.tar.gz
cd zeromq-4.2.2
./configure
sudo make install
sudo ldconfig
cd ~

echo && echo "${bold}Installing UFW...${regular}"
sleep 3
sudo apt-get -y install ufw
echo && echo "${bold}Configuring UFW...${regular}"
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 9999/tcp
sudo ufw allow 19999/tcp
echo "y" | sudo ufw enable
echo && echo "${bold}Firewall installed and enabled!${regular}"

echo && echo
echo "${bold}Downloading and installing Curium Files${regular}"
git clone https://github.com/mrmetech/Curium-Official.git
cd Curium-Official
find . -name "*.sh" -exec sudo chmod 755 {} \;
cd src/leveldb
chmod +x build_detect_platform 
make libleveldb.a libmemenv.a 
cd ../.. 
./autogen.sh
./configure --without-gui
make
cd src
strip curiumd
strip curium-cli
strip curium-tx
sudo cp curium{d,-cli,-tx} /usr/local/bin
sleep 3

echo && echo "${bold}Setting config${regular}"
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
IP_ADD=`curl ipinfo.io/ip`
mkdir -p .curium
sudo touch .curium/curium.conf
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
' | sudo -E tee /root/.curium/curium.conf
sleep 3
echo && echo "${bold}Starting Curium Deamon...${regular}"
curium-cli stop
sleep 10
curiumd -deamon &
sleep 3
echo && echo "${bold}Checking Curium Deamon...${regular}"
curiumd getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"
