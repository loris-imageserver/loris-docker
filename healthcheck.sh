#!/bin/bash
set -e
[ "$(curl --silent --output /dev/null --write '%{http_code}' http://localhost:5004/)" == 200 ]
