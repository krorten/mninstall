#!/bin/bash

clear

cd ~
echo "***********************************************************"
echo "* Welcome to Kayroons RACE masternode install script	    *"
echo "*                                                         *"
echo "* This script will install RACE MASTERNODE with Sentinel 	*"
echo "***********************************************************"
sleep 3
bold=$(tput bold)
regular=$(tput sgr0)
read -e -p "Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h) : " key
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
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libminiupnpc-dev -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev lbzip2 -y

echo && echo "${bold}Installing UFW...${regular}"
sleep 3
sudo apt-get -y install ufw
echo && echo "${bold}Configuring UFW...${regular}"
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8800/tcp
echo "y" | sudo ufw enable
echo && echo "${bold}Firewall installed and enabled!${regular}"

echo && echo
echo "${bold}Downloading and installing Race Core Files${regular}"
wget https://github.com/racecrypto/racecoin/releases/download/v0.12.2.3/racecore-0.12.2-linux64.tar.bz2
sudo tar -xjvf racecore-0.12.2-linux64.tar.bz2
rm racecore-0.12.2-linux64.tar.bz2
sudo cp racecore-0.12.2.3-linux64/race{d,-cli} /usr/local/bin

sleep 3
echo && echo "${bold}Setting config${regular}"
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
IP_ADD=`curl ipinfo.io/ip`
mkdir -p .racecore
sudo touch .racecore/race.conf
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
' | sudo -E tee /root/.racecore/race.conf
sleep 3
echo && echo "${bold}Starting Race Deamon...${regular}"
race-cli stop
sleep 3
raced -deamon &
sleep 3
cd /root/.racecore/
echo && echo "${bold}Installing Sentinel...${regular}"
sleep 3
sudo apt-get install -y git python-virtualenv
git clone https://github.com/racecrypto/sentinel.git && cd sentinel
virtualenv ./venv
./venv/bin/pip install -r requirements.txt
export EDITOR=nano
(crontab -l -u root 2>/dev/null; echo '* * * * * cd /root/.racecore/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1') | sudo crontab -u root -
cd ~
echo "race_conf=/root/.racecore/race.conf" >> /root/.racecore/sentinel/sentinel.conf
crontab -l > tempcron
echo "* * * * * cd /root/.racecore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log" >> tempcron
crontab tempcron
rm tempcron
sleep 3
echo && echo "${bold}Checking Race Deamon...${regular}"
race-cli getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"
