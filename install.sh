#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -qy

apt-get install -qy \
  vim subversion git git-core colordiff \
  tar unzip wget bzip2 libbz2-dev\
  build-essential autoconf binutils libtool zlib1g-dev \
  gfortran make cmake g++ libblas-dev liblapack-dev libboost-all-dev \
  libffi-dev libssl-dev libexpat1-dev \
  python-dev python-setuptools \
  libgeos-dev libgeos++-dev libpq-dev libproj-dev \
  munin-node munin \
  libprotobuf-c0-dev protobuf-c-compiler \
  libxml2-dev libfreetype6-dev libpng12-dev libtiff4-dev libagg-dev libgeotiff-epsg \
  libicu-dev libgdal-dev libcairo-dev libcairomm-1.0-dev gdal-bin python-gdal \
  apache2 apache2-dev apache2-utils apache2-dbg \
  liblua5.2-dev lua5.1 liblua5.1-dev ttf-unifont node-carto \
  openjdk-7-source junit

echo '127.0.0.1 localhost gis.local.osm' | cat - /etc/hosts > /tmp/out && mv /tmp/out /etc/hosts
echo "ServerName gis.local.osm" > /etc/apache2/conf-available/local-servername.conf
a2enconf local-servername
service apache2 restart

apt-get install -qy postgresql postgresql-contrib postgis postgresql-9.3-postgis-2.1

PG_VERSION=9.3
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sed -i "s/md5/trust/" "$PG_HBA"
sed -i "s/peer/trust/" "$PG_HBA"

service postgresql restart
