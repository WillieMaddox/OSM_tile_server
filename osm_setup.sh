#!/usr/bin/env bash

GISUSER=maddoxw
DB=gis

PG_VERSION=`pg_config --version | sed 's/[^0-9.]*\([0-9][.][0-9]\)[.][0-9]*/\1/'`

cat << EOF | su - postgres -c psql
DROP DATABASE IF EXISTS ${DB};
CREATE DATABASE ${DB} ENCODING 'UTF8' OWNER ${GISUSER};
\c ${DB}
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO ${GISUSER};
ALTER TABLE spatial_ref_sys OWNER TO ${GISUSER};
EOF

FLATNODESPATH=/media/OSM040/flat_nodes
mkdir -p ${FLATNODESPATH}
chown ${GISUSER}:${GISUSER} ${FLATNODESPATH}
if [[ -f ${FLATNODESPATH}/planet.cache ]]; then
    rm -rf ${FLATNODESPATH}/planet.cache
fi

PGXLOGPATH=/media/OSM070
mkdir -p ${PGXLOGPATH}
if [[ ! -L /var/lib/postgresql/${PG_VERSION}/main/pg_xlog ]]; then
    cp -rf /var/lib/postgresql/${PG_VERSION}/main/pg_xlog ${PGXLOGPATH}
    rm -rf /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
    chown -R postgres:postgres ${PGXLOGPATH}
    ln -s ${PGXLOGPATH}/pg_xlog /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
    chown -R postgres:postgres /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
    chmod 700 /var/lib/postgresql/${PG_VERSION}/main/pg_xlog

fi

SDBTBLSPCPATH=/media/OSM300
TBLSPC=main_data
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SDBTBLSPCPATH=/media/OSM150
TBLSPC=main_idx
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SDBTBLSPCPATH=/media/OSM200
TBLSPC=slim_data
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SDBTBLSPCPATH=/media/OSM325
TBLSPC=slim_idx
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

echo '##############################'
echo '##### Stylesheet config ######'
echo '##############################'

VAGRANTDIR=/home/${GISUSER}/PycharmProjects/OSM_tile_server

ZIPSDIR=${VAGRANTDIR}/data/zips
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
cp ${VAGRANTDIR}/data/mods/osm-bright.osm2pgsql.mml .
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
echo '## Setting up your webserver #'
echo '##############################'

# Move Openlayers scripts to apache dir.

cp -r ${VAGRANTDIR}/webapp/aspe_ol3_test/* /var/www/html/
chown -R www-data /var/www/html/*

# Configure renderd

mkdir -p /var/run/renderd
chown ${GISUSER} /var/run/renderd
cp ${VAGRANTDIR}/data/mods/renderd.conf /usr/local/etc/renderd.conf

# Configure mod_tile

mkdir -p /var/lib/mod_tile
chown ${GISUSER}:${GISUSER} /var/lib/mod_tile

echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" > /etc/apache2/conf-available/mod_tile.conf
cp ${VAGRANTDIR}/data/mods/000-default.conf /etc/apache2/sites-available/000-default.conf

a2enconf mod_tile
service apache2 reload
service postgresql restart
