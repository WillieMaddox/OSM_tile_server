#!/usr/bin/env bash

GISUSER=vagrant
GISPASS=vagrant
DB=gis


#PLANETDIR="/usr/local/share/maps/planet"
PLANETDIR="/vagrant/data/planet/"

#####################################################
URLBASE="http://download.geofabrik.de/north-america/us/"
PBFFILE="alabama-latest.osm.pbf"
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

MEM=`grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`
CACHE=`echo "$MEM * 0.8" | bc`

# osm2pgsql -c -d gis -U ${GISUSER}  --number-processes 4 --slim -C ${CACHE} -k --flat-nodes /var/lib/mod_tile/planet.cache ${PLANETFILE}
# --tablespace-main-data main_data --tablespace-main-index main_idx
# --tablespace-slim-data slim_data --tablespace-slim-index slim_idx
time osm2pgsql -c -d gis -U vagrant --number-processes 4 --slim -C 30000 --flat-nodes /var/lib/mod_tile/planet.cache --tablespace-main-data main_data --tablespace-main-index main_idx --tablespace-slim-data slim_data --tablespace-slim-index slim_idx /vagrant/data/planet/north-america-latest.osm.pbf
time osm2pgsql -c -d gis -U vagrant --number-processes 4 --slim -C 30000 --flat-nodes /var/lib/mod_tile/planet.cache /vagrant/data/planet/north-america-latest.osm.pbf
time osm2pgsql -c -d gis --number-processes 4 /vagrant/data/planet/alabama-latest.osm.pbf

if [[ ! -d /var/run/renderd ]]; then
    mkdir /var/run/renderd
fi
chown ${GISUSER} /var/run/renderd

# sudo install-postgis-osm-user.sh gis www-data
# sudo ln -s /home/vagrant/src/mod_tile/munin/* /etc/munin/plugins/
# sudo chmod a+x /home/vagrant/src/mod_tile/munin/*
# sudo munin-node-configure --shell | sudo sh

sudo -u ${GISUSER} renderd -f -c /usr/local/etc/renderd.conf
sudo -u vagrant renderd -f -c /usr/local/etc/renderd.conf
# Then restart apache in another terminal.
sudo service apache2 restart

cat << EOF | su - postgres -c ${DB}
ALTER TABLE public.planet_osm_ways SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE public.planet_osm_ways SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE public.planet_osm_ways SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE public.planet_osm_ways SET (autovacuum_analyze_threshold = 5000);
EOF

render_list --all -n 4 -s /var/run/renderd/renderd.sock -z 0 -Z 7

time sh -c "dd if=/dev/zero of=bigfile bs=8k count=250000 && sync"
time dd if=bigfile of=/dev/null bs=8k

dstat -tmcd -D sda1,sdb1,sdb2,sdb3,sdb4
for II in {1..4600}; do date; df | grep /dev/sdb; sleep 10; done
time osm2pgsql -c -d gis -U vagrant --number-processes 4 --slim -C 30000 --flat-nodes /var/lib/mod_tile/planet.cache --tablespace-main-data main_data --tablespace-main-index main_idx /vagrant/data/planet/north-america-latest.osm.pbf

sudo /usr/bin/install-postgis-osm-user.sh gis www-data
if [[ ! -d /var/log/tiles ]]; then
    sudo mkdir /var/log/tiles
fi
sudo chown -R www-data:www-data /var/log/tiles
PBF_CRTIME=`pbf_crtime ${PLANETFILE}`
sudo -u www-data /usr/bin/openstreetmap-tiles-update-expire ${PBF_CRTIME}
