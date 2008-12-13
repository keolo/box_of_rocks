# Ubuntu Server 8.04.1 Setup (VMWare and Linode)
2008-09-27

## Install base OS
Download and install [Ubuntu Server 64bit version](http://www.ubuntu.com/getubuntu/download).

http://users.piuha.net/martti/comp/ubuntu/en/server.html

## Check which ubuntu release is installed (just for kicks)
    lsb_release -a
    uname -a

## Update Sources and Upgrade Packages

Optionally update apt/sources.list

    vi /etc/apt/sources.list

    sudo aptitude update
    sudo aptitude dist-upgrade

## Install build tools
    sudo aptitude install build-essential

## Install SSH Server (VMWare only)
    aptitude install ssh openssh-server

## Setup for VMWare
[Link to VMWare setup](vmware_setup.md)

## Set up rsa authentication
    su deploy
    cd
    mkdir .ssh

Then from local machine:

    authme hostname
    ssh hostname

Rinse and repeat any other users that you need.

## Run As Root
    sudo -i

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

Or use the .bash_profile from my box of rocks:

    sudo aptitude install git-core
    mkdir repos
    cd repos
    git clone git://github.com/keolo/box_of_rocks.git
    git config --global user.email keolo@dreampointmedia.com
    git config --global user.name "Keolo Keagy"

Load .myrc if it exists

    vi .profile

    # Include .myrc if it exists
    if [ -f "$HOME/repos/box_of_rocks/dotfiles/.myrc" ]; then
        . "$HOME/repos/box_of_rocks/dotfiles/.myrc"
    fi

    . .profile

## Change Hostname
    hostname name

## Synchronize the System Clock
    aptitude install ntp ntpdate

## Manage users
    adduser kkeagy
    usermod -G admin kkeagy
    adduser deploy
    visudo
    deploy ALL=(ALL) ALL # Adds sudo permissions

## SSH Security by Obscurity i.e. not really that secure (optional)
Prevent cracker bots by setting a non-standard port.

    vi /etc/ssh/ssh_config
    port 8888 # or any unused port above 1024
    /etc/init.d/ssh reload

    su kkeagy
    cd
    mkdir .ssh

Copy public key authentication (executed on local machine).
    authme ip_address


## Install apache2
    sudo aptitude install apache2

## Install REE
    wget http://rubyforge.org/frs/download.php/47937/ruby-enterprise-1.8.6-20081205.tar.gz
    tar xzvf ruby-enterprise-1.8.6-20081205.tar.gz

    wget http://gist.github.com/raw/33313/b556fae6a2f1a48c6acea0f350af0f1017efd379 -O patch.diff
    cd ruby-enterprise-1.8.6-20081205 patch -p1 -E < ../patch.diff

    ./installer

If you ever want to uninstall Ruby Enterprise Edition, simply remove this
directory:

    /opt/ruby-enterprise-1.8.6-20081205

/opt/ruby-enterprise-1.8.6-20081205/bin/ruby /opt/ruby-enterprise-1.8.6-20081205/bin/gem install mysql


## Install Phusion Passenger
    /opt/ruby-enterprise-1.8.6-20081205/bin/passenger-install-apache2-module

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

## vsftpd (ftp server)
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
