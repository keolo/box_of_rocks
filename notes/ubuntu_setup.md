# Ubuntu Server Setup (VMWare and Linode)

### Install base OS
Download and install [Ubuntu Minimal Server 64bit version](https://help.ubuntu.com/community/Installation/MinimalCD).

http://users.piuha.net/martti/comp/ubuntu/en/server.html

### Install openssh (vmware only)
    sudo aptitude install openssh-server

### Create deploy user with sudo permissions
    adduser deploy
    visudo
    # Add sudo permissions to deploy user
    deploy ALL=(ALL) ALL

### Add config to vmctrl
      'vmname' => 
      {
        'path' => '/home/deploy/vmname/current',
        'port' => 22222
      },

### Set up rsa authentication
    mkdir .ssh

Then from local machine (on os x):

    authme deploy@hostname
    ssh hostname

authme can also take ssh params e.g.:
    authme "deploy@localhost -p22222"

Rinse and repeat for any other users that you need.

### [Production] Disable root login for ssh (optionally change port number)
First make sure you can login successfully with your deploy user and public key.
    ssh deploy@hostname
    sudo vi /etc/ssh/sshd_config

    # Change to the following
    PermitRootLogin no

    # Reload config file
    sudo service ssh reload

### Check which ubuntu release is installed (just for kicks)
    lsb_release -a
    uname -a

### Update Sources and Upgrade Packages

Optionally update apt/sources.list

    vi /etc/apt/sources.list

    sudo aptitude update
    sudo aptitude dist-upgrade

### Install build tools and curl
    sudo aptitude install build-essential curl

### Setup for VMWare
[VMWare setup](vmware_setup.md)

### Add .bash_profile and scripts
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

Configure global git settings:

    git config --global user.name "Keolo Keagy"
    git config --global user.email "keolo@dreampointmedia.com"

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

### Manage users (optional)
    adduser kkeagy
    usermod -G admin kkeagy

### RVM
    bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
    aptitude install build-essential bison openssl libreadline5 libreadline-dev curl git-core zlib1g zlib1g-dev libssl-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev
    rvm install 1.8.6-p369
    rvm --default 1.8.6-p369

### Ruby (it's better to use RVM instead)
    sudo aptitude install ruby ri rdoc irb ri1.8 ruby1.8-dev libzlib-ruby zlib1g libopenssl-ruby1.8
    ruby -v

### RubyGems
    cd
    mkdir src
    cd src/
    curl -LO http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
    tar xvzf rubygems-1.3.7.tgz
    cd rubygems-1.3.7
    sudo ruby setup.rb
    cd ..
    rm -rf rubygems*
    sudo ln -nfs /usr/bin/gem1.8 /usr/bin/gem
    gem -v


### MySQL
    sudo aptitude install mysql-server libmysqlclient15-dev libmysqlclient15off zlib1g-dev libmysql-ruby1.8

### Rails and dependents
    sudo gem install rails --no-rdoc --no-ri
    sudo gem install rspec --no-rdoc --no-ri
    sudo gem install rspec-rails --no-rdoc --no-ri
    sudo gem install mysql --no-rdoc --no-ri

    irb
    irb(main):001:0> require 'rubygems'
    => true
    irb(main):002:0> require 'mysql'
    => true

### Install Mongrel and Mongrel Cluster
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

### [Production] Install Nginx
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

### [Production] Configure Nginx
    http://articles.slicehost.com/2007/12/13/ubuntu-gutsy-nginx-configuration-1

### Application Setup
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

### [Production] MySQL Setup
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

### [Production] Mongrel Cluster Setup
If you set up mongrel_cluster as a service all you have to do is create a symbolic link.

    sudo ln -nfs ~/yoursite/master/current/config/mongrel/production.yml /etc/mongrel_cluster
    sudo service mongrel_cluster start
    sudo service mongrel_cluster status
    sudo service nginx status

Point your browser to your server's ip and all should be working.


### [Production] vsftpd (ftp server)
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


### Thinking Sphinx
First install Sphinx.

    curl -LO http://sphinxsearch.com/downloads/sphinx-0.9.9.tar.gz
    tar xzvf sphinx-0.9.9.tar.gz
    cd sphinx-0.9.9
    ./configure
    make
    sudo make install

Install Thinking Sphinx

    sudo gem install thinking-sphinx

Write code then update Capistrano tasks

    http://www.updrift.com/article/thinkingsphinx-capistrano-tasks

Deploy then create cron

    PATH=/usr/local/bin:/usr/bin:/bin
    SHELL=/bin/bash
    
    # Index Thinking Sphinx Search Engine every 20 mins and start if server is
    # rebooted.
    # m        h dom mon dow   command
      02,22,42 * *   *   *     cd /home/deploy/hmc/master/current && rake thinking_sphinx:index RAILS_ENV=production >> /dev/null 2>&1
      @reboot                  cd /home/deploy/hmc/master/current && rake thinking_sphinx:start RAILS_ENV=production >> /dev/null 2>&1


## The following are optional

### NTP
    sudo aptitude install ntp
    sudo vi /etc/ntp.conf
    tinker panic 0  # Add to top of file

### Sqlite3
    sudo aptitude install sqlite3 libsqlite3-dev
    sudo gem install sqlite3-ruby --no-rdoc --no-ri

### Update locate db
    updatedb

### Set hostname
    echo yourname > /etc/hostname
    hostname yourname
    sudo vi /etc/hosts

This brings up the /etc/hosts file in vim. Change the second line to match your ip, domain name and
hostname.

12.34.56.78 yourname.yourdomain.com yourname

You should also create an A record for yourname.yourdomain.com in your DNS manager.


### Oniguruma
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

### Welcome Banner
Create ascii banner [here](http://patorjk.com/software/taag/). (stampatello)

    vi /etc/motd

### Vim
If vim-tiny is not enough for you. You can try vim-nox.

    sudo aptitude install vim-nox

### OCRopus
Install via intructions here.
    http://sites.google.com/site/ocropus/install-mercurial
    * Change 'apt-get' to 'aptitude' in ocropus/ubuntu
    * I also had to copy ocr-dict-case.fst to default.fst because it was
      causing an error.

### ImageMagick and RMagick
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

### ImageScience and FreeImage
    sudo aptitude install libfreeimage-dev
    sudo gem install RubyInline --no-rdoc --no-ri
    sudo gem install image_science --no-rdoc --no-ri
