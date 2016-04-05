#!/usr/bin/env bash

GISUSER=vagrant
DB=gis

cat << EOF | su - postgres -c psql
DROP DATABASE IF EXISTS ${DB};
CREATE DATABASE ${DB} ENCODING 'UTF8' OWNER ${GISUSER};
\c ${DB}
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO ${GISUSER};
ALTER TABLE spatial_ref_sys OWNER TO ${GISUSER};
EOF

# SSDTBLSPC=/osm_nfs
HDDTBLSPCPATH=/var/lib/postgresql/9.3/main

# SSDTBLSPCPATH=/mnt/vssd/vssd

SSDTBLSPCPATH=/mnt/vssd1/vssd
TBLSPC=main_data
TBLSPCPATH=${HDDTBLSPCPATH}/${TBLSPC}
if [[ ! -d ${TBLSPCPATH} ]]; then
    mkdir -p ${TBLSPCPATH}
fi
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SSDTBLSPCPATH=/mnt/vssd2/vssd
TBLSPC=main_idx
TBLSPCPATH=${SSDTBLSPCPATH}/${TBLSPC}
if [[ ! -d ${TBLSPCPATH} ]]; then
    mkdir -p ${TBLSPCPATH}
fi
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

# SSDTBLSPCPATH=/mnt/vssd3/vssd
# TBLSPC=slim_data
# TBLSPCPATH=${SSDTBLSPCPATH}/${TBLSPC}
# if [[ ! -d ${TBLSPCPATH} ]]; then
#     mkdir -p ${TBLSPCPATH}
# fi
# chown postgres:postgres ${TBLSPCPATH}
# cat << EOF | su - postgres -c psql
# DROP TABLESPACE IF EXISTS ${TBLSPC};
# CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
# EOF

SSDTBLSPCPATH=/mnt/vssd4/vssd
TBLSPC=slim_idx
TBLSPCPATH=${HDDTBLSPCPATH}/${TBLSPC}
if [[ ! -d ${TBLSPCPATH} ]]; then
    mkdir -p ${TBLSPCPATH}
fi
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

echo '##############################'
echo '##### Stylesheet config ######'
echo '##############################'

ZIPSDIR=/vagrant/data/zips/
if [[ ! -d ${ZIPSDIR} ]]; then
    mkdir -p ${ZIPSDIR}
fi
cd ${ZIPSDIR}

# Download OSM bright

if [[ ! -f osm-bright-master.zip ]]; then
    wget https://github.com/mapbox/osm-bright/archive/master.zip -O osm-bright-master.zip
fi
if [[ ! -f simplified-land-polygons-complete-3857.zip ]]; then
    wget http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip
fi
if [[ ! -f land-polygons-split-3857.zip ]]; then
    wget http://data.openstreetmapdata.com/land-polygons-split-3857.zip
fi
if [[ ! -f ne_10m_populated_places_simple.zip ]]; then
    wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places_simple.zip
fi


STYLEDIR="/usr/local/share/maps/style"
if [[ ! -d ${STYLEDIR} ]]; then
   mkdir -p ${STYLEDIR}
fi
sudo chown ${GISUSER} ${STYLEDIR}

su - ${GISUSER}

cd ${STYLEDIR}

if [[ ! -d osm-bright-master ]]; then
    unzip ${ZIPSDIR}osm-bright-master.zip
fi
if [[ ! -d osm-bright-master/shp ]]; then
    mkdir osm-bright-master/shp
fi

cd osm-bright-master/shp

if [[ ! -f simplified-land-polygons-complete-3857/simplified-land-polygons.shp ]]; then
    unzip ${ZIPSDIR}simplified-land-polygons-complete-3857.zip
fi
if [[ ! -f land-polygons-split-3857/land-polygons.shp ]]; then
    unzip ${ZIPSDIR}land-polygons-split-3857.zip
fi
if [[ ! -f ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp ]]; then
    unzip -d ne_10m_populated_places_simple ${ZIPSDIR}ne_10m_populated_places_simple.zip
fi
if [[ ! -f land-polygons-split-3857/land-polygons.index ]]; then
    cd land-polygons-split-3857
    shapeindex land_polygons.shp
    cd ../
fi
if [[ ! -f simplified-land-polygons-complete-3857/simplified_land_polygons.index ]]; then
    cd simplified-land-polygons-complete-3857
    shapeindex simplified_land_polygons.shp
    cd ../
fi

# Configuring OSM Bright

cd ../osm-bright
rm osm-bright.osm2pgsql.mml
cp /vagrant/data/mods/osm-bright.osm2pgsql.mml .
cd ../

# Compiling the stylesheet

cp configure.py.sample configure.py
sed -i "s|\"~/Documents/MapBox/project\"|\"${STYLEDIR}\"|" configure.py
sed -i "s|\"osm\"|\"${DB}\"|" configure.py

./make.py
cd ../OSMBright/
carto project.mml > OSMBright.xml


echo '##############################'
echo '## Setting up your webserver #'
echo '##############################'

# Move Openlayers scripts to apache dir.

cp -r /vagrant/webapp/aspe_ol3_test/* /var/www/html/
chown -R www-data /var/www/html/*

# Configure renderd

if [[ ! -d /var/run/renderd ]]; then
   mkdir /var/run/renderd
fi
chown ${GISUSER} /var/run/renderd

cp /vagrant/data/mods/renderd.conf /usr/local/etc/renderd.conf

# Configure mod_tile

if [[ ! -d /var/lib/mod_tile ]]; then
   mkdir /var/lib/mod_tile
fi
chown ${GISUSER} /var/lib/mod_tile

echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/conf-available/mod_tile.conf

cp /vagrant/data/mods/000-default.conf /etc/apache2/sites-available/000-default.conf

a2enconf mod_tile
service apache2 reload

