#!/usr/bin/env bash

# - Avoid interactivity

export DEBIAN_FRONTEND=noninteractive;

# - Update the box

apt-get -y update;
apt-get -y install linux-headers-$(uname -r) build-essential;

# - Install dependencies

apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev;
apt-get -y install curl unzip;
# cryptsetup linux-source ???

# - Tweak sshd to prevent DNS resolution to speed up login

mkdir -p /etc/ssh;
rm /target/etc/issue.net && touch /target/etc/issue.net;
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config;
echo "UseDNS no" >> /etc/ssh/sshd_config;
chmod 440 /etc/ssh;

# - Remove GRUB timeout to speed up booting

sed "s/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/" /etc/default/grub;
echo "GRUB_CMDLINE_LINUX=\"biosdevname=0 net.ifnames=0\"" >> /etc/default/grub;
update-grub;

# Set up Vagrant.

date > /etc/vagrant_box_build_time

# Create the user vagrant with password vagrant
useradd -G sudo -p $(perl -e'print crypt("vagrant", "vagrant")') -m -s /bin/bash -N vagrant

# Install vagrant keys
mkdir -p /home/vagrant/.ssh;
curl -Lo /home/vagrant/.ssh/authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 755 /home/vagrant/.ssh
chmod 644 /home/vagrant/.ssh/authorized_keys;

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /var/run/motd

# Install NFS client
apt-get -y install nfs-common

# Without libdbus virtualbox would not start automatically after compile
apt-get -y install --no-install-recommends libdbus-1-3
apt-get -y install --no-install-recommends dkms

# Install the VirtualBox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop,ro $VBOX_ISO /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm /home/vagrant/VBoxGuestAdditions.iso

# Cleanup VirtualBox
rm $VBOX_ISO

###
# Install Docker
###

# Ensure that APT system can deal with HTTPS
apt-get -y install apt-transport-https

# Add official Docker repository key to local keychain
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add official Docker repository to APT sources
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list

# Update APT and install recommended packages
apt-get -y update
apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get -y install docker-engine

# Create the 'docker' system group and add 'vagrant' user to it.
# This allows the standard 'vagrant' user to use Docker without sudo'ing.
groupadd docker
gpasswd -a vagrant docker

###
# Cleanup
###

# Reducing the final size of the image to help Packer build a less big box.
# Credits to Vinicius Massuchetto and his helpful post in GitHub:
# http://vmassuchetto.github.io/2013/08/14/reducing-a-vagrant-box-size/

# Clean up APT packages
apt-get -y --purge remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
echo "Cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "Cleaning up udev rules"
rm -rfv /dev/.udev/
rm -v /lib/udev/rules.d/75-persistent-net-generator.rules

# Remove Linux headers
rm -rfv /usr/src/linux-headers*

# Remove Virtualbox specific files
rm -rfv /usr/src/vboxguest* /usr/src/virtualbox-ose-guest*

# Whiteout root
echo "Whiteouting /"
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

# Whiteout /boot
echo "Whiteouting /boot"
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

# Whiteout swap
echo "Whiteouting swap"
swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart;
dd if=/dev/zero of=$swappart;
mkswap $swappart;
swapon $swappart;

# Zero out the rest of the free space using dd.
echo "Zero out the free space to aid VM compression"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces

# - Add eth1 network interface.
# mkdir -p /target/etc/network/interfaces.d;
# echo "auto eth0" >> /target/etc/network/interfaces.d/eth0;
# echo "iface eth0 inet dhcp" >> /target/etc/network/interfaces.d/eth0;
# echo "auto eth1" >> /target/etc/network/interfaces.d/eth1;
# echo "iface eth1 inet manual" >> /target/etc/network/interfaces.d/eth1;




