
#!/bin/bash

clear

cd ~
echo "***************************************************************"
echo "* Welcome to Kayroons CROPCOIN masternode install script          *"
echo "*                                                                 *"
echo "* This script installs CROPCOIN MASTERNODE without Sentinel       *"
echo "***************************************************************"
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
sudo apt-get install libminiupnpc-dev
sudo apt-get install libdb4.8-dev libdb4.8++-dev lbzip2 -y

sleep 3
echo && echo "${bold}Installing LZIP${regular}"
wget http://download.savannah.gnu.org/releases/lzip/lzip-1.15.tar.gz
sudo tar xvf lzip-1.15.tar.gz
cd lzip-1.15
./configure --prefix=/usr
make
sudo make install
cd ~
sleep 3
echo && echo "${bold}Installing GMP${regular}"
wget https://gmplib.org/download/gmp/gmp-6.1.2.tar.lz
tar -xvf gmp-6.1.2.tar.lz
cd gmp-6.1.2
./configure
make
sudo make install
make check
cd -
rm gmp-6.1.2.tar.lz
rm lzip-1.15.tar.gz

echo && echo "${bold}Installing UFW...${regular}"
sleep 3
sudo apt-get -y install ufw
echo && echo "${bold}Configuring UFW...${regular}"
sleep 3
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 17720/tcp
echo "y" | sudo ufw enable
echo && echo "F${bold}irewall installed and enabled!${regular}"

echo && echo
echo "${bold}Downloading and installing CROPCOIN Core Files${regular}"
wget https://github.com/Cropdev/CropDev/archive/v1.0.0.3.tar.gz
tar -xvf v1.0.0.3.tar.gz
cd CropDev-1.0.0.3/src
mkdir obj/support
mkdir obj/crypto
make -f makefile.unix
strip cropcoind
chmod +x cropcoind
cd --
sudo cp CropDev-1.0.0.3/src/cropcoind /usr/local/bin

sleep 3
echo && echo "${bold}Setting config${regular}"
rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
IP_ADD=`curl ipinfo.io/ip`
mkdir -p .cropcrypto
sudo touch .cropcrypto/cropcrypto.conf
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
' | sudo -E tee /root/.cropcrypto/cropcrypto.conf
sleep 3
echo && echo "${bold}Starting CROPCOIN Deamon...${regular}"
killall cropcoind
sleep 3
cropcoind -deamon &
sleep 3

cropcoind getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"




