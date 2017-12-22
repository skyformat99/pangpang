# pangpang
High performance web server and application server for c++ and php

## wiki
[wiki](https://github.com/webcpp/pangpang/wiki)

# Benchmark

pangpang-0.8.8, 2 process VS nginx-1.13.7,2 workprocess

static file: nginx index.html

![ab](https://github.com/webcpp/pangpang/blob/master/html/ab.jpg)

![ab -k](https://github.com/webcpp/pangpang/blob/master/html/abk.jpg)

![wrk](https://github.com/webcpp/pangpang/blob/master/html/wrk.jpg)

![siege](https://github.com/webcpp/pangpang/blob/master/html/siege.jpg)

![webbench](https://github.com/webcpp/pangpang/blob/master/html/webbench.jpg)

![webbench failed](https://github.com/webcpp/pangpang/blob/master/html/webbench.failed.jpg)


# hello,world

## cpp servlet class

```cpp
#include "servlet.hpp"
namespace hi{
class hello : public servlet {
    public:

        void handler(request& req, response& res) {
            res.headers.find("Content-Type")->second = "text/plain;charset=UTF-8";
            res.content = "hello,world";
            res.status = 200;
        }

    };
}

extern "C" hi::servlet* create() {
    return new hi::hello();
}

extern "C" void destroy(hi::servlet* p) {
    delete p;
}

```

### cpp compile

```
g++ -std=c++11 -I/usr/local/pangpang/include  -shared -fPIC hello.cpp -o hello.so
install hello.so /usr/local/pangpang/mod

```

## php servlet class

see `php/hi/request.php`,`php/hi/response.php` and `php/hi/servlet.php`

```php

<?php

require_once 'hi/servlet.php';

class hello implements \hi\servlet {

    public function handler(\hi\request &$req, \hi\response &$res) {
        $res->content = 'hello,world';
        $res->status = 200;
    }

}

```

```txt

Server Software:        pangpang/0.9.2
Server Hostname:        localhost
Server Port:            9000

Document Path:          /hello.php
Document Length:        11 bytes

Concurrency Level:      1000
Time taken for tests:   39.571 seconds
Complete requests:      500000
Failed requests:        0
Write errors:           0
Total transferred:      46500000 bytes
HTML transferred:       5500000 bytes
Requests per second:    12635.61 [#/sec] (mean)
Time per request:       79.141 [ms] (mean)
Time per request:       0.079 [ms] (mean, across all concurrent requests)
Transfer rate:          1147.57 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   30  10.2     30    1031
Processing:     9   49   8.2     49     109
Waiting:        0   39   8.8     41     102
Total:         39   79  10.9     80    1092

Percentage of the requests served within a certain time (ms)
  50%     80
  66%     81
  75%     82
  80%     82
  90%     85
  95%     89
  98%     95
  99%     99
 100%   1092 (longest request)


```

```txt

Server Software:        pangpang/0.9.2
Server Hostname:        localhost
Server Port:            9000

Document Path:          /hello.php
Document Length:        11 bytes

Concurrency Level:      1000
Time taken for tests:   14.424 seconds
Complete requests:      500000
Failed requests:        0
Write errors:           0
Keep-Alive requests:    500000
Total transferred:      68500000 bytes
HTML transferred:       5500000 bytes
Requests per second:    34665.27 [#/sec] (mean)
Time per request:       28.847 [ms] (mean)
Time per request:       0.029 [ms] (mean, across all concurrent requests)
Transfer rate:          4637.83 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   1.5      0      43
Processing:     0   29  32.5      8     137
Waiting:        0   29  32.5      8     137
Total:          0   29  32.6      8     137

Percentage of the requests served within a certain time (ms)
  50%      8
  66%     62
  75%     72
  80%     73
  90%     73
  95%     75
  98%     79
  99%     84
 100%    137 (longest request)



```

# Dependency
- linux
- gcc,g++(c++11)
- hiredis-devel
- libevent-devel(2.0.21+,require 2.1.8+ if enable https )
- PHP 7.0 or later(--enable-embed=shared)

## centos
```
sudo yum install gcc gcc-c++ make pcre-devel zlib-devel openssl-devel hiredis-devel libevent-devel

```
## ubuntu
```
sudo apt-get install build-essential libpcre3-dev zlib1g-dev libssl-dev libhiredis-dev libevent-dev 

```

# Installation
`make`  and  `sudo make install` and `sudo systemctl daemon-reload` . prefix=`/usr/local/pangpang`.

# Configure
see `conf/pangpang.json`

## Run
`sudo systemctl enable pangpang`

`sudo systemctl (start|stop|restart|status) pangpang`

## Configure example
see `conf/pangpang.json` and `conf/pattern.conf`
### Base configure
```json
{
    "daemon": true,
    "multiprocess": {
        "enable": true,
        "cpu_affinity": true,
        "size": 2
    },
    "host": "127.0.0.1",
    "port": 9000,
    "ssl": {
        "enable": false,
        "cert": "",
        "key": ""
    },
    "max_headers_size": 8192,
    "max_body_size": 1048567,
    "timeout": 60,
    "gzip": {
        "enable": true,
        "min_size": 51200,
        "max_size": 307200,
        "level": -1
    },
    "session": {
        "enable": true,
        "host": "127.0.0.1",
        "port": 6379,
        "expires": 600
    },
    "log": true,
    "temp_directory": "temp",
    "route": [{
            "application_type": "cpp",
            "pattern": "hello",
            "max_match_size": 0,
            "module": "mod/hello.so",
            "cache": {
                "enable": false,
                "expires": 300,
                "size": 30
            },
            "session": false,
            "header": false,
            "cookie": false,
            "gzip": false,
            "log": false
        },
        {
            "application_type": "cpp",
            "pattern": "form",
            "max_match_size": 30,
            "module": "mod/form.so",
            "cache": {
                "enable": false,
                "expires": 300,
                "size": 30
            },
            "session": false,
            "header": true,
            "cookie": true,
            "gzip": false,
            "log": false
        },
        {
            "application_type": "cpp",
            "pattern": "session",
            "max_match_size": 0,
            "module": "mod/session.so",
            "cache": {
                "enable": false,
                "expires": 300,
                "size": 30
            },
            "session": true,
            "header": false,
            "cookie": true,
            "gzip": false,
            "log": true
        },
        {
            "application_type": "php",
            "pattern": "php",
            "max_match_size": 30,
            "module": "",
            "cache": {
                "enable": false,
                "expires": 300,
                "size": 30
            },
            "session": false,
            "header": false,
            "cookie": false,
            "gzip": false,
            "log": false
        }
    ],
    "static_server": {
        "enable": true,
        "root": "html",
        "default_content_type": "text/html",
        "list_directory": true,
        "mime": [{
                "extension": "html",
                "content_type": "text/html"
            }, {
                "extension": "txt",
                "content_type": "text/plain"
            }, {
                "extension": "js",
                "content_type": "application/x-javascript"
            },
            {
                "extension": "css",
                "content_type": "text/css"
            },
            {
                "extension": "jpg",
                "content_type": "image/jpeg"
            },
            {
                "extension": "jpeg",
                "content_type": "image/jpeg"
            },
            {
                "extension": "gif",
                "content_type": "image/gif"
            },
            {
                "extension": "png",
                "content_type": "image/png"
            },
            {
                "extension": "ico",
                "content_type": "image/x-icon"
            },
            {
                "extension": "json",
                "content_type": "application/json"
            },
            {
                "extension": "zip",
                "content_type": "application/zip"
            },
            {
                "extension": "*",
                "content_type": "application/octet-stream"
            }
        ]
    }
}


```
### Route pattern configure
```
hello       =       ^/hello/?([0-9a-z]?)?$
form        =       /form/?([0-9a-z]+)?$
session     =       /session
php         =       \.php$

```

