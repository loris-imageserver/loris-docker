FROM ubuntu:18.04

ENV HOME /root

# no ncurses prompts
ENV DEBIAN_FRONTEND noninteractive

# Update packages and install tools 
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
    gcc \
    python3-dev python3-setuptools python3-pip \
    wget git unzip \
    libjpeg8 \
    libjpeg8-dev \
    libfreetype6 \
    libfreetype6-dev \
    zlib1g-dev \
    liblcms2-2 \
    liblcms2-dev \
    liblcms2-utils \
    libtiff5-dev \
    libxml2-dev \
    libxslt1-dev

RUN python3 -m pip install --upgrade pip

# setup.py (later) depends on configobj
RUN python3 -m pip install uwsgi configobj

## kakadu is closed source and won't be installed
# Install kakadu
#WORKDIR /usr/local/lib
#RUN wget --no-check-certificate https://github.com/loris-imageserver/loris/raw/development/lib/Linux/x86_64/libkdu_v74R.so \
#	&& chmod 755 libkdu_v74R.so

#WORKDIR /usr/local/bin
#RUN wget --no-check-certificate https://github.com/loris-imageserver/loris/raw/development/bin/Linux/x86_64/kdu_expand \
#	&& chmod 755 kdu_expand

#RUN ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/ \
#	&& ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/ \
#	&& ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/ \
#	&& ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/ \
#	&& ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/ \

#RUN echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig

## apt dependencies already satisfied above
## pillow satisfied in requirements.txt
# Install Pillow
#RUN apt-get install -y libjpeg8 libjpeg8-dev libfreetype6 libfreetype6-dev zlib1g-dev liblcms2-2 liblcms2-dev liblcms2-utils libtiff5-dev
#RUN pip2.7 install Pillow

# Install loris
WORKDIR /opt

# Get loris and unzip. 
RUN wget --quiet https://github.com/loris-imageserver/loris/archive/v2.3.3.zip \
	&& unzip v2.3.3.zip \
	&& mv loris-2.3.3 loris \
	&& rm v2.3.3.zip

RUN useradd -d /var/www/loris -s /sbin/false loris

WORKDIR /opt/loris

# Create image directory
RUN mkdir /usr/local/share/images

## TODO: keep this for smoke tests?
# Load example images
RUN cp -R tests/img/* /usr/local/share/images/

## NOTE: lots of fiddling with the environment, creation of directories and permissions here
RUN python3 setup.py install
COPY loris2.conf /opt/loris/etc/loris2.conf

WORKDIR /opt/loris/loris

# bind test server to 0.0.0.0
#RUN sed -i -- 's/localhost/0.0.0.0/g' webapp.py
#RUN sed -i 's/app = create_app(debug=True)/app = create_app(debug=False, config_file_path=conf_fp)/g' webapp.py

#EXPOSE 5004
#CMD ["python", "webapp.py"]
