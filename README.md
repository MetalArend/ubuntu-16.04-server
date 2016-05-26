# Ubuntu 16.04 (Xenial Xerus) Server Vagrant base box

Standard image from http://releases.ubuntu.com/16.04/ with:
 - VBoxGuestAdditions 5.0.x
 - 10G disk
 - Predictable network interface names turned OFF (uses old style eth0, eth1)
 - `vagrant` user and password

## How to bake:

1. Install [packer.io](https://www.packer.io)
2. Run `packer build ubuntu-16.04-server-amd64.json`

## Optional

 - Save the iso file inside the iso directory: iso/ubuntu-16.04-server-amd64.iso.
   Packer will first look there, before downloading http://releases.ubuntu.com/16.04/ubuntu-16.04-server-amd64.iso.
 - Make sure the md5 is correct.
 
## Included fixes

 - https://github.com/mitchellh/vagrant/issues/7288
 - https://github.com/geerlingguy/packer-ubuntu-1604/issues/1#issuecomment-213130111
