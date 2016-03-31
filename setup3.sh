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

MEM=`grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`
CACHE=`echo "$MEM * 0.8" | bc`

# osm2pgsql -c -d gis -U ${GISUSER}  --number-processes 4 --slim -C ${CACHE} -k --flat-nodes /var/lib/mod_tile/planet.cache ${PLANETFILE}
# --tablespace-slim-index gisidxslim --tablespace-slim-data gisdatslim
# --tablespace-main-index gisidxmain --tablespace-main-data gisdatmain
# time osm2pgsql -c -d gis -U vagrant --number-processes 4 --slim -C 48000 --flat-nodes /var/lib/mod_tile/planet.cache /vagrant/data/planet/north-america-latest.osm.pbf
time osm2pgsql -c -d gis --number-processes 4 /vagrant/data/planet/alabama-latest.osm.pbf

if [[ ! -d /var/run/renderd ]]; then
    mkdir /var/run/renderd
fi
chown ${GISUSER} /var/run/renderd

cat << EOF | su - postgres -c ${DB}
ALTER TABLE public.planet_osm_ways SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE public.planet_osm_ways SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE public.planet_osm_ways SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE public.planet_osm_ways SET (autovacuum_analyze_threshold = 5000);
EOF

# echo '##############################'
# echo '##### OSM Bright config 2 ####'
# echo '##############################'

sudo -u ${GISUSER} renderd -f -c /usr/local/etc/renderd.conf
# Then restart apache in another terminal.
sudo service apache2 restart

