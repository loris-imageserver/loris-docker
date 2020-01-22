#!/bin/bash
set -e

docker run \
    --rm \
    --name loris \
    --publish 5004:5004 \
    elifesciences/loris:${IMAGE_TAG:-latest} 

# stop+remove with:
# docker rm -f loris
