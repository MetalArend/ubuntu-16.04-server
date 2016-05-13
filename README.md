# Ubuntu 16.04 (Xenial Xerus) Server Vagrant base box

Standard image from http://releases.ubuntu.com/16.04/ with:
 - VBoxGuestAdditions 5.0.x
 - 10G disk
 - Predictable network interface names turned OFF (uses old style eth0, eth1)
 - `vagrant` user and password

## How to bake:

1. Install [packer.io](https://www.packer.io)
2. Run `packer build template.json`
