#!/usr/bin/env bash

GISUSER=vagrant
SRCDIR=/vagrant

DB=gis

echo '##############################'
echo '##### Stylesheet config ######'
echo '##############################'

ZIPSDIR=${SRCDIR}/data/zips
mkdir -p ${ZIPSDIR}
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
mkdir -p ${STYLEDIR}
chown -R ${GISUSER} ${STYLEDIR}

cd ${STYLEDIR}

if [[ ! -d osm-bright-master ]]; then
    unzip ${ZIPSDIR}/osm-bright-master.zip
fi

mkdir -p osm-bright-master/shp
cd ${STYLEDIR}/osm-bright-master/shp

if [[ ! -f simplified-land-polygons-complete-3857/simplified_land_polygons.shp ]]; then
    unzip ${ZIPSDIR}/simplified-land-polygons-complete-3857.zip
fi
if [[ ! -f land-polygons-split-3857/land_polygons.shp ]]; then
    unzip ${ZIPSDIR}/land-polygons-split-3857.zip
fi
if [[ ! -f ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp ]]; then
    unzip -d ne_10m_populated_places_simple ${ZIPSDIR}/ne_10m_populated_places_simple.zip
fi
if [[ ! -f ${STYLEDIR}/osm-bright-master/shp/simplified-land-polygons-complete-3857/simplified_land_polygons.index ]]; then
    cd ${STYLEDIR}/osm-bright-master/shp/simplified-land-polygons-complete-3857
    shapeindex simplified_land_polygons.shp
fi
if [[ ! -f ${STYLEDIR}/osm-bright-master/shp/land-polygons-split-3857/land_polygons.index ]]; then
    cd ${STYLEDIR}/osm-bright-master/shp/land-polygons-split-3857
    shapeindex land_polygons.shp
fi

# Configuring OSM Bright

cd ${STYLEDIR}/osm-bright-master/osm-bright
rm osm-bright.osm2pgsql.mml
cp ${SRCDIR}/data/mods/osm-bright.osm2pgsql.mml .
cd ../

# Compiling the stylesheet

cd ${STYLEDIR}/osm-bright-master
cp configure.py.sample configure.py
sed -i "s|\"~/Documents/MapBox/project\"|\"${STYLEDIR}\"|" configure.py
sed -i "s|\"osm\"|\"${DB}\"|" configure.py
./make.py
cd ${STYLEDIR}/OSMBright
carto project.mml > OSMBright.xml

chown -R ${GISUSER} ${STYLEDIR}

echo '##############################'
echo '## Setting up the webserver ##'
echo '##############################'

# Move Openlayers scripts to apache dir.

cp -r ${SRCDIR}/webapp/aspe_ol3_test /var/www/
chown -R www-data /var/www/*

# Configure renderd

mkdir -p /var/run/renderd
chown ${GISUSER} /var/run/renderd
cp ${SRCDIR}/data/mods/renderd.conf /usr/local/etc/renderd.conf

# Configure mod_tile

mkdir -p /var/lib/mod_tile
chown ${GISUSER}:${GISUSER} /var/lib/mod_tile

echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/conf-available/mod_tile.conf
cp ${SRCDIR}/data/mods/000-default.conf /etc/apache2/sites-available/000-default.conf

a2enconf mod_tile
service apache2 reload
service postgresql restart
