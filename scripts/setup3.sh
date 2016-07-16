#!/usr/bin/env bash

GISUSER=vagrant
GISPASS=vagrant
DB=gis


#PLANETDIR="/usr/local/share/maps/planet"
PLANETDIR="/vagrant/data/planet/"

#####################################################
URLBASE="http://download.geofabrik.de/north-america/us/"
PBFFILE="alabama-latest.osm.pbf"
# PBFFILE="rhode-island-latest.osm.pbf"
## Date:   0330_2016_0036
## Nodes:         6849k
## Ways:           432k
## Relations:     2490

#####################################################
#URLBASE="http://download.geofabrik.de/north-america/"
#PBFFILE="us-south-latest.osm.pbf"
## Date:   0330_2016_0056
## Nodes:       198608k
## Ways:         14357k
## Relations:    94690

#####################################################
#URLBASE="http://download.geofabrik.de/"
#PBFFILE="north-america-latest.osm.pbf"
## Date:   0329_2016_1631
## Nodes:       813717k
## Ways:         55940k
## Relations:   505050

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

find . -name "*.md5" -exec md5sum -c {} \;

# MEM=`grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`
# CACHE=`echo "$MEM * 0.8" | bc`
# CACHE 8 bytes * number of nodes / efficiency, where efficiency is 50% for small extracts, 80% for full planet
# osm2pgsql -c -d gis -U ${GISUSER}  --number-processes 4 --slim -C ${CACHE} -k --flat-nodes /var/lib/mod_tile/planet.cache ${PLANETFILE}

# --tablespace-main-data main_data --tablespace-main-index main_idx
# --tablespace-slim-data slim_data --tablespace-slim-index slim_idx
echo `date`; time -p osm2pgsql -c -d gis -U vagrant --number-processes 12 --slim -C 30000 --flat-nodes /var/lib/mod_tile/planet.cache --tablespace-main-data main_data --tablespace-main-index main_idx --tablespace-slim-data slim_data --tablespace-slim-index slim_idx /vagrant/data/planet/planet-latest.osm.pbf
echo `date`; time -p osm2pgsql -c -d gis -U maddoxw --number-processes 12 --slim -C 30000 -k --flat-nodes /var/lib/mod_tile/planet.cache --tablespace-main-data main_data --tablespace-main-index main_index --tablespace-slim-data slim_data --tablespace-slim-index slim_index /media/Borg_LS/terrain/osm/pbf/planet-latest.osm.pbf
echo `date`; time -p osm2pgsql -c -j -G -d gis -U maddoxw --number-processes 8 --slim -C 36000 --flat-nodes /var/lib/mod_tile/planet.cache --tablespace-main-data main_data --tablespace-main-index main_index --tablespace-slim-data slim_data --tablespace-slim-index slim_index /media/Borg_LS/terrain/osm/pbf/north-america-latest.osm.pbf
sudo -u ${GISUSER} renderd -f -c /usr/local/etc/renderd.conf
sudo -u vagrant renderd -f -c /usr/local/etc/renderd.conf
# Then restart apache in another terminal.
sudo service apache2 restart

# Run after osm2pgsql
PG_VERSION=`pg_config --version | sed 's/[^0-9.]*\([0-9][.][0-9]\)[.][0-9]*/\1/'`
PG_SOURCE_DIR="/home/${GISUSER}/git/OSM_tile_server/data/mods"
PG_SOURCE_CONF="postgresql${PG_VERSION}-after.conf"
PG_TARGET_DIR="/etc/postgresql/${PG_VERSION}/main"
PG_TARGET_CONF="postgresql.conf"
PG_CONF=${PG_TARGET_DIR}/${PG_TARGET_CONF}

# copy new config
if [[ ! -f ${PG_TARGET_DIR}/${PG_SOURCE_CONF} ]]; then
    cp ${PG_SOURCE_DIR}/${PG_SOURCE_CONF} ${PG_TARGET_DIR}/${PG_SOURCE_CONF}
    chown postgres:postgres ${PG_TARGET_DIR}/${PG_SOURCE_CONF}
    chmod 644 ${PG_TARGET_DIR}/${PG_SOURCE_CONF}
fi
# remove link to config if it exists.
rm -f ${PG_CONF}
# link config
ln -s ${PG_TARGET_DIR}/${PG_SOURCE_CONF} ${PG_CONF}
chown postgres:postgres ${PG_CONF}
chmod 644 ${PG_CONF}


cat << EOF | su - postgres -c ${DB}
ALTER TABLE public.planet_osm_ways SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE public.planet_osm_ways SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE public.planet_osm_ways SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE public.planet_osm_ways SET (autovacuum_analyze_threshold = 5000);
EOF

render_list --all -n 8 -s /var/run/renderd/renderd.sock -z 0 -Z 7

time -p sh -c "dd if=/dev/zero of=bigfile bs=8k count=250000 && sync"
time -p dd if=bigfile of=/dev/null bs=8k

dstat -tmsclgd -D sda1,sdb6,sdb8,sdc1,sdc2,sdc3,sdc4 --output dstat.txt 5

# sudo install-postgis-osm-user.sh gis www-data
# sudo ln -s /home/vagrant/src/mod_tile/munin/* /etc/munin/plugins/
# sudo chmod a+x /home/vagrant/src/mod_tile/munin/*
# sudo munin-node-configure --shell | sudo sh

sudo /usr/bin/install-postgis-osm-user.sh gis www-data
if [[ ! -d /var/log/tiles ]]; then
    sudo mkdir /var/log/tiles
fi
sudo chown -R www-data:www-data /var/log/tiles
PBF_CRTIME=`pbf_crtime ${PLANETFILE}`
sudo -u www-data /usr/bin/openstreetmap-tiles-update-expire ${PBF_CRTIME}
