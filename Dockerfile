FROM ubuntu:18.04

ENV HOME /root

# No ncurses prompts
ENV DEBIAN_FRONTEND noninteractive

# Update packages and install tools 
RUN apt-get update -y --fix-missing
RUN apt-get install -y --no-install-recommends \
    gcc \
    python3-dev python3-setuptools python3-pip \
    wget curl git unzip \
    libjpeg8 \
    libjpeg8-dev \
    libjpeg-turbo8-dev \
    libfreetype6 \
    libfreetype6-dev \
    liblcms2-2 \
    liblcms2-dev \
    liblcms2-utils \
    libtiff5-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev

RUN python3 -m pip install --upgrade pip

# `configobj` is not the built in `ConfigParser` and is required to run `setup.py`
RUN python3 -m pip install uwsgi==2.0.18 configobj==5.0.6

# Install loris
WORKDIR /opt

RUN wget --quiet https://github.com/loris-imageserver/loris/archive/v3.0.0.zip \
	&& unzip v3.0.0.zip \
	&& mv loris-3.0.0 loris \
	&& rm v3.0.0.zip

RUN mkdir /usr/local/share/images


# Configure loris
WORKDIR /opt/loris

# Load example images
# TODO: keep this for smoke tests?
#RUN cp -R tests/img/* /usr/local/share/images/

# this is what uwsgi will use to init loris.
# overwrites the one generated during `setup.py`
COPY loris2.wsgi /var/www/loris2/loris2.wsgi 


# Configure uwsgi+wsgi
# the .ini file configures uwsgi and tells it where to find the `.wsgi` file
COPY uwsgi.ini /etc/loris2/uwsgi.ini

# referenced in loris2.wsgi
COPY loris2.conf etc/loris2.conf

# pillow 8.2 has a fix for corrupted tif images in it
RUN sed -i 's/pillow==6.2.0/pillow==8.2.0/' requirements.txt

# avoid setup.py in loris 3.0
RUN pip install -r requirements.txt

# new step for 3.0 that was previously part of setup.py
RUN PYTHONPATH=/opt/loris/ python3 ./bin/setup_directories.py

RUN chown www-data:www-data -R .

# heartbeat
COPY healthcheck.sh .
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD ./healthcheck.sh

# Run

EXPOSE 5004

CMD ["uwsgi", "--ini", "/etc/loris2/uwsgi.ini"]
