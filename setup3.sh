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
## Ways:           432k
## Relations:        2490

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
--tablespace-slim-index gisidxslim --tablespace-slim-data gisdatslim
--tablespace-main-index gisidxmain --tablespace-main-data gisdatmain
time osm2pgsql -c -d gis --slim -C 48000 --flat-nodes /var/lib/mod_tile/planet.cache --number-processes 4 /vagrant/data/planet/alabama-latest.osm.pbf
# if [[ ! -d /var/run/renderd ]]; then
#     mkdir /var/run/renderd
# fi
# chown ${GISUSER} /var/run/renderd

# echo '##############################'
# echo '##### OSM Bright config 2 ####'
# echo '##############################'

# renderd -f -c /usr/local/etc/renderd.conf

# Then restart apache in another terminal.

cp -r /vagrant/webapp/aspe_ol3_test/* /var/www/html/

chown -R www-data /var/www/html/*