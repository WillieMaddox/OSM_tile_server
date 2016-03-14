#!/usr/bin/env bash

GISUSER=vagrant
GISPASS=vagrant
DB=gis

echo '##############################'
echo '## Setting up your webserver #'
echo '##############################'

# Configure renderd

cp /vagrant/data/mods/renderd.conf /usr/local/etc/renderd.conf

if [[ ! -d /var/run/renderd ]]; then
    mkdir /var/run/renderd
fi
chown ${GISUSER} /var/run/renderd

if [[ ! -d /var/lib/mod_tile ]]; then
    mkdir /var/lib/mod_tile
fi
chown ${GISUSER} /var/lib/mod_tile

# Configure mod_tile

echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/conf-available/mod_tile.conf

cp /vagrant/data/mods/000-default.conf /etc/apache2/sites-available/000-default.conf

a2enconf mod_tile
service apache2 reload

echo '##############################'
echo '##### Tuning your system #####'
echo '##############################'

# Tuning postgresql

cp /vagrant/data/mods/postgresql.conf /etc/postgresql/9.3/main/postgresql.conf

echo 'kernel.shmmax=268435456' | cat - /etc/sysctl.conf > /tmp/out && mv /tmp/out /etc/sysctl.conf

service postgresql restart

#PLANETDIR="/usr/local/share/maps/planet"
#URLBASE="http://planet.openstreetmap.org/pbf/"
#PBFFILE="planet-latest.osm.pbf"

PLANETDIR="/vagrant/data/planet/"
URLBASE="http://download.geofabrik.de/north-america/us/"
PBFFILE="alabama-latest.osm.pbf"
PLANETFILE=${PLANETDIR}${PBFFILE}
URLFILE=${URLBASE}${PBFFILE}

if [[ ! -d ${PLANETDIR} ]]; then
	mkdir ${PLANETDIR}
	chown ${GISUSER} ${PLANETDIR}
fi
#cd ${PLANETDIR}

if [[ ! -f ${PLANETFILE} ]]; then
    wget ${URLFILE} -O ${PLANETFILE}
fi

osm2pgsql --slim -d ${DB} -U ${GISUSER} -C 16000 --number-processes 4 ${PLANETFILE}

if [[ ! -d /var/run/renderd ]]; then
    mkdir /var/run/renderd
fi
chown ${GISUSER} /var/run/renderd
su - ${GISUSER}

echo '##############################'
echo '##### OSM Bright config 2 ####'
echo '##############################'

renderd -f -c /usr/local/etc/renderd.conf
