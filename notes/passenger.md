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

### Apache
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
