# This is a Dockerfile to create a Unifield Environment on Ubuntu 10.04
#
# root password:    unifield
# docker user:      docker
# docker password:  docker
# psql user:        docker
# psqlpassword:     docker
#
# VERSION 0.0

# use Ubuntu 10.04 image provided by docker.io
FROM ubuntu:10.04

MAINTAINER Olivier Dossmann, olivier+dockerfile@dossmann.net

# Get noninteractive frontend for Debian to avoid some problems:
#    debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

# Ensure we create the cluster with UTF-8 locale
# Bug: https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/813398
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Set the locale
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US:en
ENV LC_ALL en_US.UTF-8

# Add OVH mirror list to update Ubuntu 10.04 to the last version.
# WARNING: Use of udev hold and initscripts hold and upstart hold will prevent:
#    dpkg: error processing udev
#    mount: permission denied
RUN echo "deb http://mirror.ovh.net/ubuntu lucid main restricted" > /etc/apt/sources.list; \
 echo "deb http://mirror.ovh.net/ubuntu/ lucid-updates main restricted" >> /etc/apt/sources.list; \
 echo "deb http://mirror.ovh.net/ubuntu/ lucid multiverse" >> /etc/apt/sources.list; \
 echo "deb http://mirror.ovh.net/ubuntu/ lucid-updates multiverse" >> /etc/apt/sources.list; \
 echo "deb http://mirror.ovh.net/ubuntu/ lucid universe" >> /etc/apt/sources.list; \
 echo "deb http://mirror.ovh.net/ubuntu/ lucid-updates universe" >> /etc/apt/sources.list; \
 echo udev hold | dpkg --set-selections; \
 echo initscripts hold | dpkg --set-selections; \
 echo upstart hold | dpkg --set-selections; \
 apt-get update; \
 apt-get upgrade -y

# Install postgresql, ssh server (access to the container), supervisord (to launch services), 
#+ tmux (to not open a lot of ssh connections), zsh and vim (to work into the container),
#+ bzr and python-argparse (for MKDB script)
RUN apt-get install -y openssh-server postgresql-8.4 supervisor tmux zsh vim bzr python-argparse

# CONFIGURATION
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN echo 'root:unifield' |chpasswd # change default root password

# Add special user docker
RUN useradd -m docker # create the home directory (-m option)
RUN echo "docker:docker" | chpasswd # change default docker password
# Permit docker user to user tmux
RUN gpasswd -a docker utmp
# Change docker user default shell
RUN chsh -s /usr/bin/zsh docker

# Add OpenERP dependancies
RUN apt-get install -y python python-psycopg2 python-reportlab python-egenix-mxdatetime python-tz python-pychart python-pydot python-lxml python-libxslt1 python-vobject python-imaging python-profiler python-setuptools python-yaml python-ldap python-cherrypy3 python-mako python-simplejson python-formencode python-pybabel flashplugin-nonfree

# Decomment the next line if you want to use Eclipse and X11 capabilities
#RUN apt-get install -y eclipse

# Found here: http://docs.docker.io/en/latest/examples/postgresql_service/
# Run the rest of the commands as the ``postgres`` user created by the ``postgres-8.4`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql-8.4 start &&\
  psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
  createdb -O docker docker

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/8.4/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/8.4/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/8.4/main/postgresql.conf

# Add configuration file to launch
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Add tmux configuration for docker user
ADD tmux.conf /home/docker/.tmux.conf
# Add vim configuration
ADD vimrc /home/docker/.vimrc
# Add zsh configuration
ADD zshrc /home/docker/.zshrc

# Open some ports: 22(SSH), 5432(POSTGRESQL), 8061(OpenERP Web Client)
EXPOSE 22 5432 8061

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Gain root permission
USER root

# Launch supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
