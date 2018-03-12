
#!/bin/bash

clear

cd ~
echo "***************************************************************"
echo "* Welcome to Kayroons CROPCOIN masternode update script         *"
echo "*                                                               *"
echo "* This script updates CROPCOIN MASTERNODE without Sentinel      *"
echo "***************************************************************"
sleep 3
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
echo && echo "${bold}Starting CROPCOIN Deamon...${regular}"
killall cropcoind
sleep 3
cropcoind -deamon &
sleep 3

cropcoind getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"




