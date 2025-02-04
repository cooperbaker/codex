#!/bin/bash
#-------------------------------------------------------------------------------
# install.sh
#
# Codex Install Script For Raspbian OS
#
# 1. Follow codex sd card flashing instructons in README.md
# 2. Run this command from a fresh OS image to install codex:
# $  curl https://raw.githubusercontent.com/cooperbaker/codex/refs/heads/main/lib/os/install.sh | bash
#
# Cooper Baker (c) 2025
# http://nyquist.dev/codex
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# install codex
#-------------------------------------------------------------------------------
sudo echo ""
echo -e "\033[1mInstalling Codex"
echo -e "\033[0m\033[1A"
echo ""


#-------------------------------------------------------------------------------
# update packages
#-------------------------------------------------------------------------------
echo -e "\033[1mUpdating Package Lists..."
echo -e "\033[0m\033[1A"
echo ""
sudo apt -y update
echo ""


#-------------------------------------------------------------------------------
# install packages
#-------------------------------------------------------------------------------
echo -e "\033[1mInstalling Packages..."
echo -e "\033[0m\033[1A"
echo ""
# sudo apt -y install jack_transport_link
# sudo apt -y install rnbo-runner-panel
sudo apt -y install samba samba-common-bin
sudo apt -y install libasound2-dev
sudo apt -y install python3-smbus
sudo apt -y install puredata
sudo apt -y install neofetch
sudo apt -v install tree
sudo apt -y install git
sudo apt -y install zsh
echo ""


#-------------------------------------------------------------------------------
# upgrade packages
#-------------------------------------------------------------------------------
echo -e "\033[1mUpgrading Packages..."
echo -e "\033[0m\033[1A"
echo ""
sudo apt -y update
sudo apt -y upgrade
sudo apt -y clean
sudo apt -y autoremove
sudo apt -y autoclean
echo ""


#-------------------------------------------------------------------------------
# install firmware
#-------------------------------------------------------------------------------
echo -e "\033[1mInstalling Codex Firmware..."
echo -e "\033[0m\033[1A"
echo ""
cd /home/pi
sudo rm -rf codex
git clone --depth 1 https://github.com/cooperbaker/codex /home/pi/codex
chmod -Rv 755 ./codex/lib/os

# compile and install device tree overlay for audio
cd /home/pi/codex/lib/os
dtc -@ -H epapr -O dtb -o codex.dtbo -Wno-unit_address_vs_reg codex.dts
sudo cp -v codex.dtbo /boot/overlays/
rm -v codex.dtbo

# compile midi driver
gcc midi.c -v -o midi -lasound -lpthread
echo ""


#-------------------------------------------------------------------------------
# install codex-pd patches
#-------------------------------------------------------------------------------
# echo -e "\033[1mInstalling Codex Pd Patches..."
# echo -e "\033[0m\033[1A"
# echo ""
# cd /home/pi
# sudo rm -rf pd
# git clone --depth 1 https://github.com/cooperbaker/codex-pd /home/pi/pd
# echo ""


#-------------------------------------------------------------------------------
# enable i2c and spi
#-------------------------------------------------------------------------------
#
#  WHAT ABOUT I2S ???
#
echo -e "\033[1mEnabling I2C and SPI..."
echo -e "\033[0m\033[1A"
echo ""
echo "sudo raspi-config nonint do_i2c 0"
echo "sudo raspi-config nonint do_spi 0"
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_spi 0
echo ""


#-------------------------------------------------------------------------------
# configure zsh
#-------------------------------------------------------------------------------
echo -e "\033[1mConfiguring ZSH..."
echo -e "\033[0m\033[1A"
echo ""
sudo chsh -s /usr/bin/zsh pi
sudo chsh -s /usr/bin/zsh root
ln -sv /home/pi/codex/lib/os/zshrc .zshrc
sudo ln -sv /home/pi/codex/lib/os/zshrc /root/.zshrc
echo ""


#-------------------------------------------------------------------------------
# edit /boot/firmware/config.txt
#-------------------------------------------------------------------------------
echo -e "\033[1mEditing /boot/firmware/config.txt..."
echo -e "\033[0m\033[1A"
echo ""
sudo rsync -auv /boot/firmware/config.txt /boot/firmware/config.txt.original
# edit existing 'dtoverlay...' declarations
echo "#dtparam=audio=on → /boot/firmware/config.txt"
sudo sed -i '/dtparam=audio=on/c\#dtparam=audio=on' /boot/firmware/config.txt
echo "dtoverlay=vc4-kms-v3d,noaudio → /boot/firmware/config.txt"
sudo sed -i '/dtoverlay=vc4-kms-v3d/c\dtoverlay=vc4-kms-v3d,noaudio' /boot/firmware/config.txt
# add 'dtoverlay...' if 'dtoverlay...' does not exist
sudo grep -qxF 'dtoverlay=codex' /boot/firmware/config.txt || echo 'dtoverlay=codex' | sudo tee -a /boot/firmware/config.txt
sudo grep -qxF 'dtoverlay=uart4-pi5' /boot/firmware/config.txt || echo 'dtoverlay=uart4-pi5' | sudo tee -a /boot/firmware/config.txt
sudo grep -qxF 'dtoverlay=midi-uart4-pi5' /boot/firmware/config.txt || echo 'dtoverlay=midi-uart4-pi5' | sudo tee -a /boot/firmware/config.txt
# apply overlays now
sudo dtoverlay -v audio
sudo dtoverlay -v uart4-pi5
sudo dtoverlay -v midi-uart4-pi-5
echo ""


#-------------------------------------------------------------------------------
# configure samba - MacOS : smb://pi:raspberry@codex/pi
#-------------------------------------------------------------------------------
echo -e "\033[1mConfiguring Samba..."
echo -e "\033[0m\033[1A"
echo ""
sudo rsync -auv /etc/samba/smb.conf /etc/samba/smb.conf.original
sudo rm -v /etc/samba/smb.conf
sudo cp -v /etc/samba/smb.conf.original /etc/samba/smb.conf
sudo cat /home/pi/codex/lib/os/smb.conf | sudo tee -a /etc/samba/smb.conf
echo "raspberry\nraspberry\n" | sudo smbpasswd -a -s pi
sudo systemctl restart smbd
sudo systemctl status smbd
echo ""


#-------------------------------------------------------------------------------
# create midi service
#-------------------------------------------------------------------------------
echo -e "\033[1mCreating Midi Service..."
echo -e "\033[0m\033[1A"
echo ""
sudo systemctl disable midi.service
sudo ln -sv /home/pi/codex/lib/os/midi.service /etc/systemd/system/midi.service
sudo systemctl enable midi.service
sudo systemctl daemon-reload
sudo systemctl start midi.service
sudo systemctl status midi.service
echo ""


#-------------------------------------------------------------------------------
# install complete
#-------------------------------------------------------------------------------
echo -e "\033[1mCodex Install Complete"
echo -e "\033[0m\033[1A"
echo ""
read -rsp $'Press any key to reboot...\n' -n1 key
sudo reboot now
echo ""


#-------------------------------------------------------------------------------
# eof
#-------------------------------------------------------------------------------
