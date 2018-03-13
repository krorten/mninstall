
#!/bin/bash

clear

cd ~
echo "***************************************************************"
echo "* Welcome to Kayroons DIXICOIN masternode update script         *"
echo "*                                                               *"
echo "* This script updates DIXICOIN MASTERNODE without Sentinel      *"
echo "***************************************************************"
sleep 3
echo && echo
echo "${bold}Downloading and installing DIXICOIN Core Files${regular}"
wget https://github.com/Dixicoin-DXC/Dixicoin/releases/download/v4.2/dixi-4.2.0-aarch64-linux-gnu.zip
unzip dixi-4.2.0-aarch64-linux-gnu.zip
rm dixi-4.2.0-aarch64-linux-gnu.zip
sudo cp dixi-4.2.0-aarch64-linux-gnu/dixicoin{d,-cli} /usr/local/bin
sudo chmod +x /usr/local/bin/dixicoind
sudo chmod +x /usr/local/bin/dixicoin-cli
sleep 3
cd --
echo && echo "${bold}Restarting DIXI Deamon...${regular}"
dixicoin-cli stop
sleep 10
dixicoind -deamon &
sleep 3
dixicoin-cli getinfo
echo && echo "${bold}Have a beer and enjoy! Masternode setup is complete.${regular}"
