honeypot-setup-script
=====================
**Use with caution**: This script will happily and without prompt overwrite files, change the port your SSH server runs and all sorts. It is intended to be run on a vanilla install of Ubuntu 12.04. No thoughts have been made for the integrity of existing installations of softwar - so be careful!

A script to install and deploy a honeypot automatically and without user interaction. 

Currently installs and sets up:

* kippo
* dionaea
* p0f

These will all be installed as system services so running this script once should turn a vanilla install in to a robust honeypot. Aims to use useful _and secure_ defaults. 

Usage
---------------------
wget -q -O - http://pastebin.com/raw.php?i=VURksJnn | bash

Notes
---------------------
If your SSH server is running on Port 22 This will change your SSH port to 66534 by editing `/etc/ssh/sshd_config`. This is to allow kippo monitor traffic on that port.

