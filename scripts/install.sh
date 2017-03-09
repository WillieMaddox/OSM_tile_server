#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

UBUNTU_VERSION=`lsb_release -sc`
apt-get update
apt-get upgrade -qy

apt-get install -qy htop dstat sysstat parted git git-core

apt-get install -qy apache2 apache2-dev apache2-utils apache2-dbg
if ! grep "gis.local.osm" /etc/hosts; then
    sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost gis.local.osm/" /etc/hosts
fi
echo "ServerName gis.local.osm" > /etc/apache2/conf-available/local-servername.conf
a2enconf local-servername
service apache2 restart

apt-get install -qy cachefilesd
sed -i "s/#RUN=yes/RUN=yes/" /etc/default/cachefilesd
service cachefilesd start

apt-get install -qy \
  vim colordiff tar unzip wget bzip2 libbz2-dev \
  build-essential autoconf binutils libtool zlib1g-dev \
  gfortran make cmake g++ libblas-dev liblapack-dev libboost-all-dev \
  libffi-dev libssl-dev libexpat1-dev \
  python-dev python-setuptools python-nose python-cairo-dev \
  libgeos-dev libgeos++-dev libpq-dev libproj-dev \
  libdbd-pg-perl protobuf-c-compiler librasterlite-dev \
  libxml2-dev libfreetype6-dev libpng12-dev libagg-dev \
  libicu-dev libcairo2-dev libcairomm-1.0-dev libgeotiff-epsg geotiff-bin \
  liblua5.2-dev lua5.1 liblua5.1-0-dev ttf-unifont

case ${UBUNTU_VERSION} in
    'trusty' )
        apt-get install -qy \
        libprotobuf-c0-dev \
        libtiff4-dev \
        openjdk-7-source junit
        ;;
    'xenial' )
        apt-get install -qy \
        libprotobuf-c-dev \
        libtiff5-dev \
        openjdk-8-source junit
        ;;
esac

apt-get install -qy libgdal-dev gdal-bin python-gdal

apt-get install -qy node-carto
# apt-get install -qy nfs-common portmap

apt-get install -qy munin-node munin

apt-get install -qy postgresql postgresql-contrib postgis python-psycopg2

# set shmmax to the size of postgresql shared_buffers or 2*size.
# echo 'kernel.shmmax=8589934592' | cat - /etc/sysctl.conf > /tmp/out && mv /tmp/out /etc/sysctl.conf
# echo 'kernel.shmmax=17179869184' | cat - /etc/sysctl.conf > /tmp/out && mv /tmp/out /etc/sysctl.conf

PG_VERSION=`pg_config --version | sed 's/[^0-9.]*\([0-9][.][0-9]\)[.][0-9]/\1/'`
PG_CONF=/etc/postgresql/${PG_VERSION}/main/postgresql.conf
PG_HBA=/etc/postgresql/${PG_VERSION}/main/pg_hba.conf
PG_DIR=/var/lib/postgresql/${PG_VERSION}/main

# Tuning postgresql

cp ${PG_CONF} ${PG_CONF}.orig
cp /vagrant/data/mods/postgresql${PG_VERSION}-before.conf ${PG_CONF}
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "${PG_CONF}"
sed -i "s/md5/trust/" "${PG_HBA}"
sed -i "s/peer/trust/" "${PG_HBA}"

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

