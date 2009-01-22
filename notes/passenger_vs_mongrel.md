# Phusion Passenger vs. Mongrel (testing a simple rails 2.2 app)
My findings were fairly similar to [this](http://www.pervasivecode.com/blog/2008/04/14/why-mod_rails-is-a-really-good-thing-for-light-duty-ruby-on-rails/).
Tested with:

    ab -c 50 -n 500 [host]/test

### Apache2 mpm-prefork + Passenger + REE (with tcmalloc patch) + ubuntu-minimal 8.10 64bit

 * First request takes 3-7 seconds (cold start). If there are no requests after a few minutes, a
   cold start is required again.
 * If you have less than 1GB of RAM, Passenger is likely to swap memory (even after tweaking apache
   prefork settings). This can drasticly hurt your app's performance on a vps.
 * Log rotation is cleaner?
 * Tied to REE version of ruby
 * Don't need to manage mongrel clusters
 * When the vm started swaping I was getting 25 req/sec or timeouts. After tweaking the prefork
   config in httpd.conf, performance was around 125 req/sec. Some swaping still occured though.
   reduce the amount of swaping
 * Response times were miliseconds slower than Nginx + Mongrel.

Tweaks to prefork module in httpd.conf to help trim memory consumption.

    <IfModule prefork.c>
        StartServers 1
        MinSpareServers 5
        MaxSpareServers 10
        MaxClients 150 # Should set to 2 or 3?
        MaxRequestsPerChild 0
    </IfModule>


### Nginx 0.5.33 + Mongrel + ubuntu-minimal 8.04 64bit

 * First request is sub second
 * Runs fine on 360MB of RAM - no swaping
 * Log rotation might be troublesome?
 * Long running process locks up mongrel
 * Can run newer versions of ruby (good for security)
 * Need to manage mongrel clusters
 * Performance was around 110-125 req/sec consistently.
 * Response times were a few miliseconds faster than Apache + Passenger.


## Lazy Testing

Here's some unscientific metrics of Passenger vs. Passenger + REE on the same vm instance (1 virtual
processor, 512MB ram). I was too lazy to set up a test for Nginx + Mongrel.

    ab -c 50 -n 2000 [host]/test

### Passenger:

    Server Software:        Apache/2.2.9
    Server Hostname:        local
    Server Port:            80

    Document Path:          /test
    Document Length:        8145 bytes

    Concurrency Level:      50
    Time taken for tests:   32.890 seconds
    Complete requests:      2000
    Failed requests:        0
    Write errors:           0
    Total transferred:      17412061 bytes
    HTML transferred:       16290000 bytes
    Requests per second:    60.81 [#/sec] (mean)
    Time per request:       822.256 [ms] (mean)
    Time per request:       16.445 [ms] (mean, across all concurrent requests)
    Transfer rate:          516.99 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    1   1.8      0      50
    Processing:   108  814 190.8    733    1413
    Waiting:      107  814 190.8    732    1412
    Total:        113  815 190.7    733    1413

    Percentage of the requests served within a certain time (ms)
      50%    733
      66%    808
      75%   1037
      80%   1049
      90%   1091
      95%   1118
      98%   1132
      99%   1181
     100%   1413 (longest request)


### Passenger + REE (without tcmalloc patch):

    Server Software:        Apache/2.2.9
    Server Hostname:        local
    Server Port:            80

    Document Path:          /test
    Document Length:        8145 bytes

    Concurrency Level:      50
    Time taken for tests:   27.970 seconds
    Complete requests:      2000
    Failed requests:        0
    Write errors:           0
    Total transferred:      17412066 bytes
    HTML transferred:       16290000 bytes
    Requests per second:    71.50 [#/sec] (mean)
    Time per request:       699.255 [ms] (mean)
    Time per request:       13.985 [ms] (mean, across all concurrent requests)
    Transfer rate:          607.93 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    1   0.9      0      11
    Processing:    63  688 182.9    600    1045
    Waiting:       62  687 182.9    599    1044
    Total:         69  688 182.6    600    1045
    WARNING: The median and mean for the initial connection time are not within a normal deviation
            These results are probably not that reliable.

    Percentage of the requests served within a certain time (ms)
      50%    600
      66%    714
      75%    904
      80%    915
      90%    957
      95%    971
      98%    996
      99%   1017
     100%   1045 (longest request)


    # free -m
              total       used       free     shared    buffers     cached
    Mem:           497        392        104          0          5         69
    -/+ buffers/cache:        317        179
    Swap:          400         34        365




### Passenger + REE (with tcmalloc patch):

    Server Software:        Apache/2.2.9
    Server Hostname:        local
    Server Port:            80

    Document Path:          /test
    Document Length:        8145 bytes

    Concurrency Level:      50
    Time taken for tests:   25.922 seconds
    Complete requests:      2000
    Failed requests:        0
    Write errors:           0
    Total transferred:      17412056 bytes
    HTML transferred:       16290000 bytes
    Requests per second:    77.16 [#/sec] (mean)
    Time per request:       648.041 [ms] (mean)
    Time per request:       12.961 [ms] (mean, across all concurrent requests)
    Transfer rate:          655.98 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    1   1.1      0      13
    Processing:    74  641 162.6    561     947
    Waiting:       74  641 162.6    561     946
    Total:         81  642 162.4    562     947

    Percentage of the requests served within a certain time (ms)
      50%    562
      66%    804
      75%    831
      80%    840
      90%    859
      95%    881
      98%    897
      99%    907
     100%    947 (longest request)


     # free -m
                  total       used       free     shared    buffers     cached
     Mem:           497        451         45          0         11        139
     -/+ buffers/cache:        299        197
     Swap:          400         34        365






## Changed the test to better model traffic I'm expecting

    ab -c 20 -n 2000 [host]/test


### Apache + Passenger + REE (with tmalloc)
In this second test Apache + Passenger + REE (with tmalloc) gets better req/s but still swaps
memory.

    Server Software:        Apache/2.2.9
    Server Hostname:        local
    Server Port:            80

    Document Path:          /test
    Document Length:        2841 bytes

    Concurrency Level:      20
    Time taken for tests:   17.810 seconds
    Complete requests:      2000
    Failed requests:        0
    Write errors:           0
    Total transferred:      6803865 bytes
    HTML transferred:       5682000 bytes
    Requests per second:    112.30 [#/sec] (mean)
    Time per request:       178.097 [ms] (mean)
    Time per request:       8.905 [ms] (mean, across all concurrent requests)
    Transfer rate:          373.08 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    2   2.7      1      20
    Processing:    12  175 341.8    137    7103
    Waiting:       11  174 341.8    136    7103
    Total:         13  177 341.8    139    7108

    Percentage of the requests served within a certain time (ms)
      50%    139
      66%    157
      75%    170
      80%    178
      90%    251
      95%    414
      98%    511
      99%    623
     100%   7108 (longest request)


    # free -m
                 total       used       free     shared    buffers     cached
    Mem:           497        482         14          0          0         21
    -/+ buffers/cache:        461         35
    Swap:          400          7        392


### Nginx + Mongrel
No memory swaping here. Maybe mongrel is better for smaller apps? I'm only using 3 mongrels and
nginx takes up less memory than apache.

    Server Software:        nginx/0.6.32
    Server Hostname:        local
    Server Port:            80

    Document Path:          /test
    Document Length:        2853 bytes

    Concurrency Level:      20
    Time taken for tests:   20.536 seconds
    Complete requests:      2000
    Failed requests:        0
    Write errors:           0
    Total transferred:      6627618 bytes
    HTML transferred:       5706000 bytes
    Requests per second:    97.39 [#/sec] (mean)
    Time per request:       205.358 [ms] (mean)
    Time per request:       10.268 [ms] (mean, across all concurrent requests)
    Transfer rate:          315.17 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    2   2.6      1      23
    Processing:    13  202 131.4    182     867
    Waiting:       12  201 131.4    181     866
    Total:         14  204 131.3    183     867

    Percentage of the requests served within a certain time (ms)
      50%    183
      66%    257
      75%    300
      80%    324
      90%    392
      95%    430
      98%    485
      99%    534
     100%    867 (longest request)


     # free -m
                  total       used       free     shared    buffers     cached
     Mem:           497        342        154          0          7         87
     -/+ buffers/cache:        247        249
     Swap:          400          0        400


