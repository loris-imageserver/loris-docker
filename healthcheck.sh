#!/bin/bash
set -e
# 2020-03: disabled, uwsgi is now talking uwsgi not http.
#[ "$(curl --silent --output /dev/null --write '%{http_code}' http://localhost:5004/)" == 200 ]

# tests that a socket is open and exits immediately with 1 or 0
# not as good as the http test above
#nc --zero --verbose localhost 5004 # gnu-netcat

# -w timeout (seconds)
# -v verbose
nc localhost 5004 -v -w 1
