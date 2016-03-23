#!/usr/bin/env bash

GISUSER=vagrant
GISPASS=vagrant
DB=gis

#PLANETDIR="/usr/local/share/maps/planet"
PLANETDIR="/vagrant/data/planet/"

#####################################################
URLBASE="http://download.geofabrik.de/north-america/us/"
PBFFILE="alabama-latest.osm.pbf"
## Date:   0311_2016_1751
## Nodes:         6849k
## Ways:
## Relations:

#####################################################
#URLBASE="http://download.geofabrik.de/"
#PBFFILE="north-america-latest.osm.pbf"
## Date:   0314_2016_1726
## Nodes:       811758k
## Ways:         55940k
## Relations:      505050

#####################################################
#URLBASE="http://planet.openstreetmap.org/pbf/"
#PBFFILE="planet-latest.osm.pbf"
## Nodes:
## Ways:
## Relations:

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
# time osm2pgsql -c -d gis --tablespace-index gisidx --tablespace-main-data gisdatmain --tablespace-main-index gisidxmain --tablespace-slim-data gisdatslim --tablespace-slim-index gisidxslim --slim -C 28000 --flat-nodes /var/lib/mod_tile/planet.cache --number-processes 4 /vagrant/data/planet/alabama-latest.osm.pbf
# if [[ ! -d /var/run/renderd ]]; then
#     mkdir /var/run/renderd
# fi
# chown ${GISUSER} /var/run/renderd

# echo '##############################'
# echo '##### OSM Bright config 2 ####'
# echo '##############################'

# renderd -f -c /usr/local/etc/renderd.conf
