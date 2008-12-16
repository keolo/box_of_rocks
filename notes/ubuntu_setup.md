# Ubuntu Server 8.04.1 Setup (VMWare and Linode)
2008-09-27

## Install base OS
Download and install [Ubuntu Server 64bit version](http://www.ubuntu.com/getubuntu/download).

http://users.piuha.net/martti/comp/ubuntu/en/server.html

## Create deploy user with sudo permissions
    adduser deploy
    visudo
    deploy ALL=(ALL) ALL # Adds sudo permissions

## Set up rsa authentication
    su - deploy
    mkdir .ssh

Then from local machine:

    authme deploy@hostname
    ssh hostname

Rinse and repeat any other users that you need.

## Disable root login for ssh (optionally change port number)
First make sure you can login successfully with your deploy user and public key.
    ssh deploy@hostname
    sudo vi /etc/ssh/sshd_config

    # Change to the following
    PermitRootLogin no

    # Reload config file
    sudo service ssh reload

## ubuntu-minimal
On linode they install ubuntu-minimal. This means for 8.10 aptitude and other software isn't
installed by default. But that's easy enough to solve.

    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install aptitude

## Check which ubuntu release is installed (just for kicks)
    lsb_release -a
    uname -a

## Update Sources and Upgrade Packages

Optionally update apt/sources.list

    vi /etc/apt/sources.list

    sudo aptitude update
    sudo aptitude dist-upgrade

## Install build tools
    sudo aptitude install build-essential wget

## Setup for VMWare
[Link to VMWare setup](vmware_setup.md)

## Run As Root (optional)
You can optionally switch to root to run the following commands. Although, getting in the habit of
using sudo isn a better idea.

    sudo -i

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

    cd
    vi .profile

Add this to the bottom of ~/.profile

    # Include .myrc if it exists
    if [ -f "$HOME/repos/box_of_rocks/dotfiles/.myrc" ]; then
        . "$HOME/repos/box_of_rocks/dotfiles/.myrc"
    fi

Reload bash profile

    . .profile

## Change Hostname (very optional)
    hostname name

## Manage users (optional)
    adduser kkeagy
    usermod -G admin kkeagy

## SSH Security by Obscurity i.e. not really that secure (optional)
Prevent cracker bots by setting a non-standard port.

    vi /etc/ssh/ssh_config
    port 8888 # or any unused port above 1024
    /etc/init.d/ssh reload

    su kkeagy
    cd
    mkdir .ssh

## Apache
    sudo aptitude install apache2-mpm-prefork apache2-prefork-dev

After everything else is set up and you want to optimize apache for performance.

    cd /etc/apache2
    sudo vi /mods-available/deflate.conf

    <IfModule mod_deflate.c>
      AddOutputFilterByType DEFLATE text/plain text/html text/css text/xml application/xml application/xml+rss text/javascript application/javascript
    </IfModule>

    sudo vi /mods-available/expires.conf

    ExpiresActive On
    ExpiresByType image/gif "access plus 10 years"
    ExpiresByType image/png "access plus 10 years"
    ExpiresByType image/jpg "access plus 10 years"
    ExpiresByType image/jpeg "access plus 10 years"
    ExpiresByType text/css "access plus 10 years"
    ExpiresByType application/javascript "access plus 10 years"
    ExpiresByType text/xml "access plus 10 years"
    ExpiresByType application/x-shockwave-flash "access plus 10 years"

    sudo a2enmod expires

    apache2ctl -t

    sudo service apache2 restart

## Ruby
    sudo aptitude install ruby ri rdoc irb ri1.8 ruby1.8-dev libzlib-ruby zlib1g libopenssl-ruby1.8
    ruby -v

## RubyGems
    cd
    mkdir src
    cd src/
    wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz
    tar xvzf rubygems-1.3.1.tgz
    cd rubygems-1.3.1
    sudo ruby setup.rb
    cd ..
    rm -rf *
    sudo ln -nfs /usr/bin/gem1.8 /usr/bin/gem

## Install Phusion Passenger
    sudo gem install passenger --no-rdoc --no-ri
    sudo passenger-install-apache2-module

    cd /etc/apache2/
    sudo vi mods-available/passenger.load

Add these lines to passenger.load

    LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.5/ext/apache2/mod_passenger.so
    PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.5
    PassengerRuby /usr/bin/ruby1.8

Enable passenger module

    sudo a2enmod passenger

Create vhost and disable default site

    sudo vi sites-available/[your_site]

    <VirtualHost *:80>
       ServerName www.your_site.com
       DocumentRoot /home/deploy/[your_site]/master/current/public
    </VirtualHost>

    sudo a2ensite [your_site]
    sudo a2dissite default

Check config and then restart apache

    apache2ctl -t
    sudo service apache2 restart


## Install REE (optional)
    wget http://rubyforge.org/frs/download.php/47937/ruby-enterprise-1.8.6-20081205.tar.gz
    tar xzvf ruby-enterprise-1.8.6-20081205.tar.gz

Patch REE to use tcmalloc. Taken from [here](http://sethbc.org/2008/12/07/ruby-enterprise-edition-on-ubuntu-810-x86_64/).

    # Cut and paste this to patch.diff
    http://gist.github.com/raw/33313/b556fae6a2f1a48c6acea0f350af0f1017efd379

    cd ruby-enterprise-1.8.6-20081205
    patch -p1 -E < ../patch.diff
    # Make sure there's no errors when patching

Run REE installer.

    sudo ./installer

Create symbolic link to ruby gems

    sudo ln -nfs /opt/ruby-enterprise-1.8.6-20081205/bin/gem /usr/bin/gem

## Sqlite3 (optional)
    sudo aptitude install sqlite3 libsqlite3-dev
    sudo gem install sqlite3-ruby --no-rdoc --no-ri

## MySQL
    sudo aptitude install mysql-server libmysqlclient15-dev libmysqlclient15off zlib1g-dev libmysql-ruby1.8

## MySQL User(s)
    # log in as the mysql root user
    create user 'someuser'@'localhost' identified by 'somepassword';
    grant insert, select, update, delete, drop, create, index on db_test.* to 'someuser'@'localhost';
    grant insert, select, update, delete, drop, create, index on db_development.* to 'someuser'@'localhost';
    grant insert, select, update, delete, drop, create, index on db_production.* to 'someuser'@'localhost';

To see a list of the privileges that have been granted to a specific user:

    select * from mysql.user where User='user' \G

To change password

    set password for username@localhost=password('new_password');

## Rails and dependents
    sudo gem install rails --no-rdoc --no-ri
    sudo gem install rspec --no-rdoc --no-ri
    sudo gem install mysql --no-rdoc --no-ri

    irb
    irb(main):001:0> require 'rubygems'
    => true
    irb(main):002:0> require 'mysql'
    => true

## Install Mongrel and Mongrel Cluster
    sudo gem install mongrel --no-rdoc --no-ri
    sudo gem install mongrel_cluster --no-rdoc --no-ri

To start mongrel cluster on boot, copy the mongrel_cluster script file to `/etc/init.d`. Run
`gem env` to find out where your ruby gems are installed.

    1. Create mongrel_cluster conf directory (/etc/mongrel_cluster).
    2. Copy the init.d script from mongrel_cluster’s resouces directory to /etc/init.d.
       sudo cp /usr/lib/ruby/gems/1.8/gems/mongrel_cluster-1.0.5/resources/mongrel_cluster /etc/init.d/
    3. sudo chmod +x /etc/init.d/mongrel_cluster
    4. Add to init.d startup. On ubuntu: “sudo update-rc.d mongrel_cluster defaults”
    5. Comment out the “USER=mongrel” line and the “chown $USER:$USER $PID_DIR” in mongrel_cluster.

## Install Nginx
    sudo aptitude install nginx

    # Some commands to mangage nginx
    sudo service nginx start
    sudo service nginx stop
    sudo service nginx restart
    sudo service nginx status

    sudo vi /etc/nginx/sites-available/default
    sudo vi /etc/nginx/nginx.conf

    # Test configuration
    sudo /usr/sbin/nginx -t

## Configure Nginx
    http://articles.slicehost.com/2007/12/13/ubuntu-gutsy-nginx-configuration-1

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

## Update locate db (optional)
    updatedb

## Set hostname
    echo yourname > /etc/hostname
    hostname yourname
    sudo vi /etc/hosts

This brings up the /etc/hosts file in vim. Change the second line to match your ip, domain name and
hostname.

12.34.56.78 yourname.yourdomain.com yourname

You should also create an A record for yourname.yourdomain.com in your DNS manager.


## Welcome Banner
Create ascii banner [here](http://patorjk.com/software/taag/). (stampatello)

    vi /etc/motd
