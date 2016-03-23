#!/usr/bin/env bash

GISUSER=vagrant
GISPASS=vagrant
DB=gis

echo '##############################'
echo '##### Adding Ubuntu user #####'
echo '##############################'

# Need to figure out how to make this work.
# Adding the password flag -p when creating the user is not secure.
#sudo useradd -m ${GISUSER}
#sudo passwd ${GISUSER} < ${GISPASS}
if [[ ${GISUSER} != vagrant ]]; then
    useradd -m ${GISUSER} -p ${GISPASS}
fi

echo '##############################'
echo '##### Adding postgres user ###'
echo '##############################'

cat << EOF | su - postgres -c psql
CREATE USER ${GISUSER} WITH SUPERUSER PASSWORD '${GISPASS}';
EOF

# cat << EOF | su - postgres
# createdb -E UTF8 -O ${GISUSER} ${DB}
# EOF

GISTBSPACE=/osm_nfs

if [[ ! -d ${GISTBSPACE}/gisdata ]]; then
  mkdir -p ${GISTBSPACE}/gisdata
fi
cat << EOF | su - postgres -c psql
CREATE TABLESPACE gisdata OWNER ${GISUSER} LOCATION '${GISTBSPACE}/gisdata';
EOF

if [[ ! -d ${GISTBSPACE}/gisidx ]]; then
  mkdir -p ${GISTBSPACE}/gisidx
fi
cat << EOF | su - postgres -c psql
CREATE TABLESPACE gisidx OWNER ${GISUSER} LOCATION '${GISTBSPACE}/gisidx';
EOF

if [[ ! -d ${GISTBSPACE}/gisidxmain ]]; then
  mkdir -p ${GISTBSPACE}/gisidxmain
fi
cat << EOF | su - postgres -c psql
CREATE TABLESPACE gisidxmain OWNER ${GISUSER} LOCATION '${GISTBSPACE}/gisidxmain';
EOF

if [[ ! -d ${GISTBSPACE}/gisdatmain ]]; then
  mkdir -p ${GISTBSPACE}/gisdatmain
fi
cat << EOF | su - postgres -c psql
CREATE TABLESPACE gisdatmain OWNER ${GISUSER} LOCATION '${GISTBSPACE}/gisdatmain';
EOF

if [[ ! -d ${GISTBSPACE}/gisidxslim ]]; then
  mkdir -p ${GISTBSPACE}/gisidxslim
fi
cat << EOF | su - postgres -c psql
CREATE TABLESPACE gisidxslim OWNER ${GISUSER} LOCATION '${GISTBSPACE}/gisidxslim';
EOF

if [[ ! -d ${GISTBSPACE}/gisdatslim ]]; then
  mkdir -p ${GISTBSPACE}/gisdatslim
fi
cat << EOF | su - postgres -c psql
CREATE TABLESPACE gisdatslim OWNER ${GISUSER} LOCATION '${GISTBSPACE}/gisdatslim';
EOF

cat << EOF | su - postgres -c psql
CREATE DATABASE ${DB} ENCODING 'UTF8' OWNER ${GISUSER} TABLESPACE gisdata;
EOF

cat << EOF | su - postgres -c "psql -d ${DB}"
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO ${GISUSER};
ALTER TABLE spatial_ref_sys OWNER TO ${GISUSER};
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

