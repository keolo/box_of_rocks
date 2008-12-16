# VMWare Setup
These are instructions for setting up Ubuntu on VMWare.

## Install SSH Server
    aptitude install ssh openssh-server

## Login Via SSH (VMWare only)
Set VMWare networking to bridged. Might need to restart networking.

    sudo service networking restart
    ssh user@ip # From local machine (run ifconfig to get ip)

## Networking
Ethernet MAC addresses are cached. Remove this file to clear the cache.

    sudo rm /etc/udev/rules.d/70-persistent-net.rules
    sudo vi /etc/hosts - change ip address and hostnames
    sudo vi /etc/hostname - change hostname
    sudo vi /etc/network/interfaces - change ip address

http://www.cyberciti.biz/tips/howto-ubuntu-linux-convert-dhcp-network-configuration-to-static-ip-configuration.html

## Install VMWare tools (VMWare only)
### amd64 users
    aptitude install ia32-libs

    aptitude install build-essential linux-headers-server libgtk2.0-dev
    aptitude install libproc-dev libdumbnet-dev xorg-dev libicu38 libicu-dev

    cd /usr/local/src/
    wget http://downloads.sourceforge.net/open-vm-tools/open-vm-tools-2008.07.01-102166.tar.gz?modtime=1214928542&big_mirror=0
    tar xvzf open-vm-tools-2008.05.15-93241.tar.gz
    cd open-vm-tools-2008.05.15-93241/
    ./configure && make
    cd modules/linux/
    for i in *; do mv ${i} ${i}-only; tar -cf ${i}.tar ${i}-only; done

Virtual Machine > Install VMWare Tools

    mount /cdrom

    cd /usr/local/src
    sudo cp /cdrom/VMwareTools-*.tar.gz .
    sudo tar xf VMwareTools-*.tar.gz
    mv -f open-vm-tools-2008.05.15-93241/modules/linux/*.tar vmware-tools-distrib/lib/modules/source/
    sudo ./vmware-tools-distrib/vmware-install.pl

Make sure there are no errors/failures. Shared directories should work after restart.

    sudo shutdown -r now
    ls /mnt/hgfs/shared_dir/

Cleanup
   sudo rm -rf /usr/local/src/*

http://www.howtoforge.com/perfect-server-ubuntu8.04-lts-p3

## Configure Networking (static ip) (VMWare only)
    vi /etc/network/interfaces

    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    # The loopback network interface
    auto lo
    iface lo inet loopback

    # The primary network interface
    auto eth0
    #iface eth0 inet dhcp
    iface eth0 inet static
            address 192.168.1.200
            netmask 255.255.255.0
            network 192.168.1.0
            broadcast 192.168.1.255
            gateway 192.168.1.1


    /etc/init.d/networking restart

Then edit /etc/hosts. Make it look like this:

    vi /etc/hosts

    127.0.0.1       localhost.localdomain   localhost
    192.168.0.100   server1.example.com     server1
    # The following lines are desirable for IPv6 capable hosts
    ::1     ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts

Now run

    echo server1.example.com > /etc/hostname
    /etc/init.d/hostname.sh start

Afterwards, run

    hostname
    hostname -f

Both should show server1.example.com now.
