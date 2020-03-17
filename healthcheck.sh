#!/bin/bash
set -e
# 2020-03: disabled, uwsgi is now talking uwsgi not http. how to test uWSGI is available?
#[ "$(curl --silent --output /dev/null --write '%{http_code}' http://localhost:5004/)" == 200 ]
