#!/bin/bash
set -e

docker run \
    --rm \
    --name loris \
    --publish 5004:5004 \
    loris 

# stop+remove with:
# docker rm -f loris--inst
