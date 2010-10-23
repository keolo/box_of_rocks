# Nginx Config

## Development
    # vhost configuration

    # This is where you define your mongrel clusters.
    # you need one of these blocks for each cluster
    # and each one needs its own name to refer to it later.
    upstream mongrel_cluster_development {
      server 0.0.0.0:8000;
    }

    #
    # Begin virtual host configuration
    #
    server {
      # Port to listen on. Can also be set to an IP:PORT
      listen 3000;

      # Sets the domain(s) that this vhost server requests for
      # server_name www.[domain].com [domain].com;
      server_name localhost;

      # Enable directory indexing
      # autoindex on;

      # Vhost specific access and error logs
      access_log /home/deploy/yourapp/current/log/nginx/access.log;
      error_log /home/deploy/yourapp/current/log/nginx/error.log debug;

      # This rewrites all the requests to the maintenance.html
      # page if it exists in the doc root. This is for capistrano's
      # disable web task.
      if (-f $document_root/system/maintenance.html) {
        rewrite ^(.*)$ /system/maintenance.html last;
        break;
      }

      location / {
        # Document root
        root /home/deploy/yourapp/current/public;
        index index.html index.htm;

        # Needed to forward user's IP address to rails
        proxy_set_header X-Real-IP $remote_addr;

        # Needed for HTTPS
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_max_temp_file_size 0;

        # Short-circuit all non-GET requests
        # to be served by mongrel and not nginx.
        if ($request_method != GET) {
          proxy_pass http://mongrel_cluster_development;
          break;
        }

        # Add expires headers for static content.
        location ~ ^/(images|javascripts|stylesheets|flash)/ {
          expires max;
        }

        # If the file exists as a static file serve it directly without
        # running all the other rewite tests on it.
        if (-f $request_filename) {
          break;
        }

        # Check for index.html for directory index
        # if its there on the filesystem then rewite
        # the url to add /index.html to the end of it
        # and then break to send it to the next config rules.
        if (-f $request_filename/index.html) {
          rewrite (.*) $1/index.html break;
        }

        # This is the meat of the rails page caching config
        # it adds .html to the end of the url and then checks
        # the filesystem for that file. If it exists, then we
        # rewite the url to have explicit .html on the end
        # and then send it on its way to the next config rule.
        # If there is no file on the fs then it sets all the
        # necessary headers and proxies to our upstream mongrels.
        #
        # Note: use $uri, not $request_filename; and no / between
        # /cache and $uri or $1
        #
        # try turning foo/7 into cache/foo/7.html
        if (-f $document_root/cache$uri.html) {
          rewrite (.*) /cache$1.html
          break;
        }
        # try turning foo/ into cache/foo/index.html
        if (-f $document_root/cache$uri/index.html) {
           rewrite (.*) /cache$1/index.html
           break;
        }
        # OK, fine then. try turning foo/7.html into cache/foo/7.html
        if (-f $document_root/cache$uri) {
          rewrite (.*) /cache$1
          break;
        }
        # Otherwise let Mongrel handle the request
        if (!-f $request_filename) {
          proxy_pass http://mongrel_cluster_development;
          break;
        }
      }

      # Redirect server error pages to the static page /500.html
      error_page 500 502 503 504 /500.html;
      location = /500.html {
        root /home/deploy/yourapp/current/public;
      }
    }
