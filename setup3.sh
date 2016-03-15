#!/usr/bin/env bash

GISUSER=vagrant
GISPASS=vagrant
DB=gis

#PLANETDIR="/usr/local/share/maps/planet"
PLANETDIR="/vagrant/data/planet/"

URLBASE="http://download.geofabrik.de/north-america/us/"
PBFFILE="alabama-latest.osm.pbf"
#URLBASE="http://download.geofabrik.de/"
#PBFFILE="north-america-latest.osm.pbf"
#URLBASE="http://planet.openstreetmap.org/pbf/"
#PBFFILE="planet-latest.osm.pbf"

PLANETFILE=${PLANETDIR}${PBFFILE}
URLFILE=${URLBASE}${PBFFILE}

if [[ ! -d ${PLANETDIR} ]]; then
  mkdir ${PLANETDIR}
  chown ${GISUSER} ${PLANETDIR}
fi

if [[ ! -f ${PLANETFILE} ]]; then
    wget ${URLFILE} -O ${PLANETFILE}
fi

# osm2pgsql -c -d gis -U ${GISUSER} --slim -C 24000 -k --flat-nodes /var/lib/mod_tile/planet.cache --number-processes 4  ${PLANETFILE}
# osm2pgsql -c -d gis --slim -C 16000 -k --number-processes 2 /vagrant/data/planet/north-america-latest.osm.pbf
# if [[ ! -d /var/run/renderd ]]; then
#     mkdir /var/run/renderd
# fi
# chown ${GISUSER} /var/run/renderd

# echo '##############################'
# echo '##### OSM Bright config 2 ####'
# echo '##############################'

# renderd -f -c /usr/local/etc/renderd.conf
