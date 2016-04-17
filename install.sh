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

sudo apt-get install \
  vim subversion git git-core colordiff \
  tar unzip wget bzip2 libbz2-dev \
  build-essential autoconf binutils libtool zlib1g-dev \
  gfortran make cmake g++ libblas-dev liblapack-dev libboost-all-dev \
  libffi-dev libssl-dev libexpat1-dev \
  python-dev python-setuptools python-nose python-cairo-dev \
  libgeos-dev libgeos++-dev libpq-dev libproj-dev \
  munin-node munin libdbd-pg-perl \
  libprotobuf-c-dev protobuf-c-compiler \
  libxml2-dev libfreetype6-dev libpng12-dev libtiff5-dev libagg-dev libgeotiff-epsg \
  libicu-dev libgdal-dev libcairo2-dev libcairomm-1.0-dev gdal-bin geotiff-bin python-gdal \
  liblua5.2-dev lua5.1 liblua5.1-0-dev ttf-unifont node-carto \
  openjdk-8-source junit

#   nfs-common portmap \

sudo apt-get install postgresql postgresql-contrib postgis postgresql-9.5-postgis-2.2 python-psycopg2

# set shmmax to the size of postgresql shared_buffers or 2*size.
# echo 'kernel.shmmax=8589934592' | cat - /etc/sysctl.conf > /tmp/out && mv /tmp/out /etc/sysctl.conf
# echo 'kernel.shmmax=17179869184' | cat - /etc/sysctl.conf > /tmp/out && mv /tmp/out /etc/sysctl.conf

PG_VERSION=9.5
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Tuning postgresql

# cp /vagrant/data/mods/postgresql9.5.conf ${PG_CONF}
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sed -i "s/md5/trust/" "$PG_HBA"
sed -i "s/peer/trust/" "$PG_HBA"

service postgresql restart

GISUSER=maddoxw
GISPASS=maddoxw
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

