#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -qy

apt-get install -qy htop dstat sysstat parted

apt-get install -qy apache2 apache2-dev apache2-utils apache2-dbg
# echo '127.0.0.1 localhost gis.local.osm' | cat - /etc/hosts > /tmp/out && mv /tmp/out /etc/hosts
echo "ServerName gis.local.osm" > /etc/apache2/conf-available/local-servername.conf
a2enconf local-servername
service apache2 restart

apt-get install -qy cachefilesd
sed -i "s/#RUN=yes/RUN=yes/" /etc/default/cachefilesd
service cachefilesd start

apt-get install -qy \
  vim subversion git git-core colordiff \
  tar unzip wget bzip2 libbz2-dev \
  build-essential autoconf binutils libtool zlib1g-dev \
  nfs-common portmap \
  gfortran make cmake g++ libblas-dev liblapack-dev libboost-all-dev \
  libffi-dev libssl-dev libexpat1-dev \
  python-dev python-setuptools python-nose python-cairo-dev \
  libgeos-dev libgeos++-dev libpq-dev libproj-dev \
  munin-node munin \
  libprotobuf-c0-dev protobuf-c-compiler \
  libxml2-dev libfreetype6-dev libpng12-dev libtiff4-dev libagg-dev libgeotiff-epsg \
  libicu-dev libgdal-dev libcairo-dev libcairomm-1.0-dev gdal-bin python-gdal \
  liblua5.2-dev lua5.1 liblua5.1-dev ttf-unifont node-carto \
  openjdk-7-source junit

apt-get install -qy postgresql postgresql-contrib postgis postgresql-9.3-postgis-2.1 python-psycopg2

PG_VERSION=9.3
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Tuning postgresql

# cp /vagrant/data/mods/postgresql.conf ${PG_CONF}
# echo 'kernel.shmmax=8589934592' | cat - /etc/sysctl.conf > /tmp/out && mv /tmp/out /etc/sysctl.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sed -i "s/md5/trust/" "$PG_HBA"
sed -i "s/peer/trust/" "$PG_HBA"

service postgresql restart

GISUSER=vagrant
GISPASS=vagrant
DB=gis

### Adding Ubuntu user

# Need to figure out how to make this work.
# Adding the password flag -p when creating the user is not secure.
#sudo useradd -m ${GISUSER}
#sudo passwd ${GISUSER} < ${GISPASS}
if [[ ${GISUSER} != vagrant ]]; then
    useradd -m ${GISUSER} -p ${GISPASS}
fi

### Adding postgres user

cat << EOF | su - postgres -c psql
CREATE USER ${GISUSER} WITH SUPERUSER PASSWORD '${GISPASS}';
EOF

