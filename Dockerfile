FROM ubuntu:18.04

ENV HOME /root

# No ncurses prompts
ENV DEBIAN_FRONTEND noninteractive

# Update packages and install tools 
RUN apt-get update -y
RUN apt-get install -y --no-install-recommends \
    gcc \
    python3-dev python3-setuptools python3-pip \
    wget curl git unzip \
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

# `configobj` is not the built in `ConfigParser` and is required to run `setup.py`
RUN python3 -m pip install uwsgi==2.0.18 configobj==5.0.6

# `newrelic` here is the NewRelic APM agent. 
# if the container is run with the envvar `NEW_RELIC_ENABLED` equal to `true`, then the 
# WSGI loris application will be wrapped by the `newrelic` agent.
RUN python3 -m pip install newrelic==5.8.0.136


# [kakadu is closed source and won't be installed]


# Install loris
WORKDIR /opt

RUN wget --quiet https://github.com/loris-imageserver/loris/archive/v2.3.3.zip \
	&& unzip v2.3.3.zip \
	&& mv loris-2.3.3 loris \
	&& rm v2.3.3.zip

RUN useradd --home /var/www/loris --shell /sbin/false --uid 1005 loris

RUN mkdir /usr/local/share/images


# Configure loris
WORKDIR /opt/loris

# Load example images
# TODO: keep this for smoke tests?
RUN cp -R tests/img/* /usr/local/share/images/

# note: setup.py does lots of fiddling with the environment, creation of directories, permissions, 
# copying and generating files. just let it do it's thing and we'll override anything afterwards.
RUN python3 setup.py install
COPY loris2.conf etc/loris2.conf


# Configure uwsgi+wsgi
# the .ini file configures uwsgi and tells it where to find the `.wsgi` file
COPY uwsgi.ini /etc/loris2/uwsgi.ini

# this is what uwsgi will use to init loris.
# overwrites the one generated during `setup.py`
COPY loris2.wsgi /var/www/loris2/loris2.wsgi 

# heartbeat
COPY healthcheck.sh .
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD ./healthcheck.sh

# Run

EXPOSE 5004

CMD ["uwsgi", "--ini", "/etc/loris2/uwsgi.ini"]
