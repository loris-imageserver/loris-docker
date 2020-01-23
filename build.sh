#!/bin/bash
docker build --tag elifesciences/loris:${IMAGE_TAG:-latest} .
