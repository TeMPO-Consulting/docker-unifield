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

# Install postgresql, ssh and supervisord (to launch
RUN apt-get install -y openssh-server postgresql-8.4 supervisor tmux zsh vim-tiny

# Configuration
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN echo 'root:unifield' |chpasswd # change default root password

# Add special user docker
RUN useradd docker
RUN echo "docker:docker" | chpasswd

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

# Open some ports: 22(SSH), 5432(POSTGRESQL)
EXPOSE 22 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Gain root permission
USER root

# Launch supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
