# Ubuntu Server 8.04.1 Setup (VMWare and Linode)
2008-09-27

## Install base OS
Download and install [Ubuntu Server 64bit version](http://www.ubuntu.com/getubuntu/download).

http://users.piuha.net/martti/comp/ubuntu/en/server.html

## Create deploy user with sudo permissions
    adduser deploy
    visudo
    # Add sudo permissions to deploy user
    deploy ALL=(ALL) ALL

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
    sudo aptitude install build-essential curl

## Setup for VMWare
[Link to VMWare setup](vmware_setup.md)

## Run As Root (optional)
You can optionally switch to root to run the following commands. Although, getting in the habit of
using sudo isn a better idea.

    sudo -i

## Add .bash_profile and scripts
You can do this manually (manual - not recommened):

    vi /etc/skel/.bashrc
    vi /etc/profile
    exit
    vi ~/.bashrc

Or use the .myrc from my box of rocks (recommended):

    sudo aptitude install git-core
    mkdir repos
    cd repos
    git clone git://github.com/keolo/box_of_rocks.git

Load .myrc if it exists

    cd
    vi .profile

Add this to the bottom of ~/.profile. Optionally, you can comment out loading .bashrc if you don't
want the ubuntu defaults like color highlighting (I like to comment it out).

    # Include .myrc if it exists
    if [ -f "$HOME/repos/box_of_rocks/dotfiles/.myrc" ]; then
        . "$HOME/repos/box_of_rocks/dotfiles/.myrc"
    fi

Reload bash profile

    . .profile

## Manage users (optional)
    adduser kkeagy
    usermod -G admin kkeagy

## Apache (only install this if you're going to use passenger!)
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
    curl -LO http://rubyforge.org/frs/download.php/57643/rubygems-1.3.4.tgz
    tar xvzf rubygems-1.3.4.tgz
    cd rubygems-1.3.4
    sudo ruby setup.rb
    cd ..
    rm -rf rubygems*
    sudo ln -nfs /usr/bin/gem1.8 /usr/bin/gem
    gem -v

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

## Rails and dependents
    sudo gem install rails --no-rdoc --no-ri
    sudo gem install rspec --no-rdoc --no-ri
    sudo gem install rspec-rails --no-rdoc --no-ri
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
       sudo vi /etc/init.d/mongrel_cluster
    6. Test if it works (might want to try rebooting to see if that works too)
       sudo service mongrel_cluster status
       sudo reboot

## Install Nginx
    sudo aptitude install nginx

    # Some commands to mangage nginx
    sudo service nginx start
    sudo service nginx stop
    sudo service nginx restart
    sudo service nginx status

    # Start nginx
    sudo service nginx start

Type your server's ip into a web browser. You should see a message that nginx is working.

If you have some nginx templates copy them to these files or create your own. These are synonymous
to apache vhosts.

    cd /etc/nginx
    sudo cp nginx.conf nginx.orig.conf
    sudo vi nginx.conf
    sudo vi sites-available/yoursite

Enable your site and disable the default.

    sudo ln -nfs /etc/nginx/sites-available/yoursite sites-enabled/
    sudo rm sites-enabled/default

Test the configuration and reload the nginx configs.

    sudo /usr/sbin/nginx -t
    sudo service reload

Create a test file in the directory specified by the document root in your nginx vhost config.

    mkdir -p ~/yoursite/master/current/public
    vi ~/yoursite/master/current/public/index.html

Insert some text into index.html and type your server's ip into a web browser. You should see your
text if everything is working correctly.

## Configure Nginx
    http://articles.slicehost.com/2007/12/13/ubuntu-gutsy-nginx-configuration-1

## Application Setup
Pull in project from github. Before we set up capistrano it's a good idea to test your application
stack.

If your repo is private you'll need to
[add your public key](http://github.com/guides/providing-your-ssh-key#linux) so you can pull in the
code.

Once that's done clone your repo to the document root specified in the nginx vhost config.

    cd ~/yoursite/master
    rm -rf current
    git clone git@github.com:you/yourproject.git current
    cd current

## MySQL Setup
    cp config/database.template.yml config/database.yml
    # Update database config
    vi config/database.yml

    # Log in as the mysql root user
    create user someuser@localhost identified by 'somepassword';
    grant insert, select, update, delete, drop, create, alter, index on db_test.* to someuser@localhost;
    grant insert, select, update, delete, drop, create, alter, index on db_development.* to someuser@localhost;
    grant insert, select, update, delete, drop, create, alter, index on db_production.* to someuser@localhost;

    # To change password
    set password for username@localhost=password('new_password');

    # Try logging in as the new user. Should see the above databases.
    rake db:create:all
    mysql -u someuser -p    or   ./script/dbconsole
    show databases;

    rake db:migrate RAILS_ENV=production

## Mongrel Cluster Setup
If you set up mongrel_cluster as a service all you have to do is create a symbolic link.

    sudo ln -nfs ~/yoursite/master/current/config/mongrel/production.yml /etc/mongrel_cluster
    sudo service mongrel_cluster start
    sudo service mongrel_cluster status
    sudo service nginx status

Point your browser to your server's ip and all should be working.

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
[vsftpd](http://en.gentoo-wiki.com/wiki/Vsftpd)

    sudo aptitude install vsftpd

Test (from client)

    ftp anonymous@server
    ls -la

Add false shell

    sudo vi /etc/shells
    /bin/false # Add to list

Edit config

    sudo vi /etc/vsftpd.conf
    anonymous_enable=NO
    local_enable=YES
    write_enable=YES
    chroot_local_user=YES
    local_umask=002

Create ftp group

    sudo groupadd ftp

Create user with no shell and the primary group ftp

    sudo useradd userftp -d /home/userftp -s /bin/false
    sudo passwd userftp

Restart ftp server and test

    sudo service vsftpd restart
    ftp userftp@host
    ssh userftp@host


## Oniguruma
Oniguruma is a regex library that is better than the one built into Ruby 1.8.
It supports named groups, look-ahead, look-behind, and other cool features!
This libraby is supposedly baked into Ruby 1.9.

    # Installation (for Ruby 1.8)
    curl -LO http://www.geocities.jp/kosako3/oniguruma/archive/onig-5.9.1.tar.gz
    tar zxf onig-5.9.1.tar.gz
    cd onig-5.9.1
    ./configure --prefix=/usr/local
    sudo make
    sudo make install
    sudo gem install oniguruma

    # Synopsis:
    reg = Oniguruma::ORegex.new('(?<before>.*)(a)(?<after>.*)')
    match = reg.match('terraforming')
    puts match[0]       <= 'terraforming'
    puts match[:before] <= 'terr'
    puts match[:after]  <= 'forming'


## Thinking Sphinx
First install Sphinx.

    curl -LO http://www.sphinxsearch.com/downloads/sphinx-0.9.8.1.tar.gz
    tar zxvf sphinx-0.9.8.1.tar.gz
    cd sphinx-0.9.8.1
    ./configure
    make
    sudo make install

Install Thinking Sphinx plugin

    script/plugin install git://github.com/freelancing-god/thinking-sphinx.git

Write code then update Capistrano tasks

    http://www.updrift.com/article/deploying-a-rails-app-with-thinking-sphinx

Deploy then create cron

    PATH=/usr/local/bin:/usr/bin:/bin
    SHELL=/bin/bash
    
    # Index Thinking Sphinx Search Engine every 20 mins and start if server is
    # rebooted.
    # m        h dom mon dow   command
      02,22,42 * *   *   *     cd /home/deploy/hmc/master/current && rake thinking_sphinx:index RAILS_ENV=production >> /dev/null 2>&1
      @reboot                  cd /home/deploy/hmc/master/current && rake thinking_sphinx:start RAILS_ENV=production >> /dev/null 2>&1


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

## Vim
If vim-tiny is not enough for you. You can try vim-nox.

    sudo aptitude install vim-nox

## OCRopus
Install via intructions here.
    http://sites.google.com/site/ocropus/install-mercurial
    * Change 'apt-get' to 'aptitude' in ocropus/ubuntu
    * I also had to copy ocr-dict-case.fst to default.fst because it was
      causing an error.
