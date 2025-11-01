ab -n 100 -c 10 http://elros.K34.com/api/airing
ab -n 2000 -c 100 http://elros.K34.com/api/airing

# contoh response

# root@Aldarion:~# ab -n 100 -c 10 http://elros.K34.com/api/airing
# This is ApacheBench, Version 2.3 <$Revision: 1923142 $>
# Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
# Licensed to The Apache Software Foundation, http://www.apache.org/

# Benchmarking elros.K34.com (be patient).....done


# Server Software:        nginx
# Server Hostname:        elros.K34.com
# Server Port:            80

# Document Path:          /api/airing
# Document Length:        6619 bytes

# Concurrency Level:      10
# Time taken for tests:   0.136 seconds
# Complete requests:      100
# Failed requests:        0 (KEREN COI)
# Non-2xx responses:      100
# Total transferred:      692700 bytes
# HTML transferred:       661900 bytes
# Requests per second:    733.64 [#/sec] (mean)
# Time per request:       13.631 [ms] (mean)
# Time per request:       1.363 [ms] (mean, across all concurrent requests)
# Transfer rate:          4962.80 [Kbytes/sec] received

# Connection Times (ms)
#               min  mean[+/-sd] median   max
# Connect:        0    1   0.6      1       3
# Processing:     7   11   3.3     10      26
# Waiting:        6   10   3.2     10      26
# Total:          8   12   3.2     11      27

# Percentage of the requests served within a certain time (ms)
#   50%     11
#   66%     12
#   75%     13
#   80%     14
#   90%     17
#   95%     18
#   98%     20
#   99%     27
#  100%     27 (longest request)
