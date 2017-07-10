**Note:** This repository has not been maintained all that well. Fixes are welcome, but you might also want to look at https://github.com/bodleian/loris-grok-docker

Docker build of Loris IIIF Image Server
===========

Docker container running [Loris IIIF Image Server](https://github.com/loris-imageserver/loris)

**Warning** : the actual version is a simple way to have loris works, but the server is the developpement werkzeug server with debugging enabled. Hence not suitable for developpement purpose.

### Use  pre-built image
Download image from docker hub.

    $ docker pull lorisimageserver/loris

### Build from scratch
Use local Dockerfile to build image.

    $ docker build -t your_image_name .

### Start the container and test

    $ docker run -d -p 5004:5004 lorisimageserver/loris

Point your browser to `http://<Host or Container IP>:5004/01/02/0001.jp2/full/full/0/default.jpg`

### Use your own image folder

Add your image directory as a volume

    $ docker run -d -v <your-img-folder>:/usr/local/share/images -p 5004:5004 <docker-image>

### Use samba to load images
Add the images directory as a volume and mount on a Samba or sshd container. [(See svendowideit/samba)](https://registry.hub.docker.com/u/svendowideit/samba/)

    $ docker run --name loris -v /usr/local/share/images -d -p 5004:5004 lorisimageserver/loris
    $ docker run --rm -v /usr/local/bin/docker:/docker -v /var/run/docker.sock:/docker.sock svendowideit/samba loris
    

### Create loris cluster
Create data volume container

    $ docker run --name loris_data -v /usr/local/share/images -v /var/cache/loris -d ubuntu echo Data only container for loris images and cache

Create two loris server containers with shared image and cache volumes    

    $ docker run --name loris_server_1 --volumes-from loris_data -d lorisimageserver/loris
    $ docker run --name loris_server_2 --volumes-from loris_data -d lorisimageserver/loris
    
Build nginx image with custom config

    $ cd nginx
    $ docker build -t lorisimageserver/nginx .

Run nginx proxy

    $ docker run --name loris_proxy  --link loris_server_1:server1 --link loris_server_2:server2 -d -p 80:80 lorisimageserver/nginx
