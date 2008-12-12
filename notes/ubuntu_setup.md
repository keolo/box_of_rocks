# Ubuntu Server 8.04.1 Setup (VMWare and Linode)
2008-09-27

## Install base OS
Download and install [Ubuntu Server 64bit version](http://www.ubuntu.com/getubuntu/download).

Maybe [easyvmx](http://easyvmx.com) works too?

http://users.piuha.net/martti/comp/ubuntu/en/server.html
http://sysadminschronicles.com/articles/2008/05/06/ubuntu-8-04-rails-server-using-passenger

## Check which ubuntu release is installed
    lsb_release -a

## Create kkeagy user
    adduser kkeagy
    visudo
    kkeagy ALL=(ALL) ALL

## Set up rsa authentication
    su kkeagy
    cd
    mkdir .ssh

Then from local machine:

    authme hostname
    ssh hostname

## Run As Root
    sudo -i

## Install build tools
    sudo aptitude install build-essential

## Update Sources and Upgrade Packages

Optionally update apt/sources.list

    vi /etc/apt/sources.list

    aptitude update
    aptitude dist-upgrade

## Install SSH Server (VMWare only)
    aptitude install ssh openssh-server

## Login Via SSH (VMWare only)
Set VMWare networking to bridged. Might need to restart networking.

    /etc/init.d/networking restart
    ssh user@host

## Networking
Ethernet MAC addresses are cached. Remove this file to clear the cache.

    sudo rm /etc/udev/rules.d/70-persistent-net.rules
    sudo vi /etc/hosts - change ip address and hostnames
    sudo vi /etc/hostname - change hostname
    sudo vi /etc/network/interfaces - change ip address

http://www.cyberciti.biz/tips/howto-ubuntu-linux-convert-dhcp-network-configuration-to-static-ip-configuration.html

## Disable SSH root login
    sudo vi /etc/ssh/sshd_config
    Protocol 2
    PermitRootLogin no
    sudo /etc/init.d/ssh restart

## Add .bash_profile and scripts
You can do this manually:

    vi /etc/skel/.bashrc
    vi /etc/profile
    exit
    vi ~/.bashrc

Or use the .bash_profile from my git repository:

    aptitude install git-core
    mkdir repos
    cd repos
    git clone git://github.com/keolo/box_of_rocks.git
    git config user.email keolo@dreampointmedia.com
    git config user.name "Keolo Keagy"

Load .myrc if it exists

    vi .profile

    # include .kkeagyrc if it exists
    if [ -f "$HOME/scripts/dotfiles/.myrc" ]; then
        . "$HOME/scripts/dotfiles/.myrc"
    fi

    . .profile

## Git
    git push origin branch_name
    git checkout -b branch_name
    git pull origin branch_name

## Change Hostname
    hostname name

## Synchronize the System Clock
    aptitude install ntp ntpdate

## Install vim-full (is there a non-gtk version?)
    aptitude install vim-full

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
    cp /cdrom/VMwareTools-*.tar.gz .
    tar xf VMwareTools-*.tar.gz
    mv -f open-vm-tools-2008.05.15-93241/modules/linux/*.tar vmware-tools-distrib/lib/modules/source/
    ./vmware-tools-distrib/vmware-install.pl

Make sure there are no errors/failures. Shared directories should work after restart.

    shutdown -r now
    ls /mnt/hgfs/shared_dir/

Cleanup
    rm -rf /usr/local/src/*

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

## Manage users
    adduser kkeagy
    usermod -G admin kkeagy
    adduser deploy
    visudo
    deploy ALL=(ALL) ALL

## SSH Security by Obscurity (optional)
Prevent cracker bots by setting a non-standard port.

    vi /etc/ssh/ssh_config
    port 8888 # or any unused port above 1024
    /etc/init.d/ssh reload

    su kkeagy
    cd
    mkdir .ssh

Copy public key authentication (executed on local machine).
    authme ip_address

## Install Nginx
    sudo aptitude install nginx

    sudo /etc/init.d/nginx start
    sudo /etc/init.d/nginx stop
    sudo /etc/init.d/nginx restart

    sudo vi /etc/nginx/sites-available/default
    sudo vi /etc/nginx/nginx.conf

    # Test configuration
    sudo /usr/sbin/nginx -t

## Configure Nginx
    http://articles.slicehost.com/2007/12/13/ubuntu-gutsy-nginx-configuration-1

## Ruby
    aptitude install ruby ri rdoc irb ri1.8 ruby1.8-dev libzlib-ruby zlib1g libopenssl-ruby1.8
    ruby -v

## RubyGems
    cd /usr/local/src/
    sudo curl -LO http://rubyforge.org/frs/download.php/43985/rubygems-1.3.0.tgz
    tar xvzf rubygems-1.3.0.tgz
    cd rubygems-1.3.0
    ruby setup.rb
    cd -
    rm -rf *
    sudo ln -s /usr/bin/gem1.8 /usr/bin/gem

## Sqlite3
    sudo aptitude install sqlite3 libsqlite3-dev
    sudo gem install sqlite3-ruby --no-rdoc --no-ri

## MySQL
    sudo aptitude install mysql-server libmysqlclient15-dev libmysqlclient15off zlib1g-dev libmysql-ruby1.8

    irb
    irb(main):001:0> require 'rubygems'
    => true
    irb(main):002:0> require 'mysql'
    => true

## MySQL User(s)
    # log in as the mysql root user
    create user 'someuser'@'localhost' identified by 'somepassword';
    grant insert, select, update, delete on db_test.* to 'someuser'@'localhost';
    grant insert, select, update, delete on db_development.* to 'someuser'@'localhost';
    grant insert, select, update, delet  on db_production.* to 'someuser'@'localhost';

To see a list of the privileges that have been granted to a specific user:

    select * from mysql.user where User='user' \G

To change password

    set password for username@localhost=password('new_password');

## Rails
    sudo gem install rails --no-rdoc --no-ri
    sudo gem install mongrel mongrel_cluster --no-rdoc --no-ri
    sudo gem install rspec --no-rdoc --no-ri
    sudo gem install mysql --no-rdoc --no-ri

## ImageMagick and RMagick
    aptitude install imagemagick librmagick-ruby1.8 libfreetype6-dev xml-core
    irb(main):003:0> require 'RMagick'
    => true
    irb(main):004:0> include Magick
    => Object
    irb(main):005:0> img = ImageList.new 'test.jpg'
    => [test.jpg JPEG 690x430 690x430+0+0 DirectClass 8-bit 47kb]
    scene=0
    irb(main):006:0> img.write 'test.png'
    => [test.jpg=>test.png JPEG 690x430 690x430+0+0 DirectClass 8-bit 393kb]
    scene=0

## ImageScience and FreeImage
    sudo aptitude install libfreeimage-dev
    sudo gem install RubyInline --no-rdoc --no-ri
    sudo gem install image_science --no-rdoc --no-ri

## vsftpd
    sudo aptitude install vsftpd

Test (from client)

    ftp anonymous@server
    dir

Add false shell

    sudo vi /etc/shells
    /bin/false # Add to list

Edit config

    sudo vi /etc/vsftpd.conf
    anonymous_enable=NO
    local_enable=YES
    write_enable=YES
    chroot_local_user=YES

Create user with no shell

    sudo useradd userftp -d /home/userftp -s /bin/false
    sudo passwd userftp

Restart ftp server and test

    sudo /etc/init.d/vsftpd restart
    ftp userftp@host
    ssh userftp@host

## Update locate db
    updatedb

## Welcome Banner
Create ascii banner [here](http://patorjk.com/software/taag/). (stampatello)

    vi /etc/motd

## Upgrade ubuntu to newest release (e.g. 8.04 - 8.10)
    sudo do-release-upgrade
