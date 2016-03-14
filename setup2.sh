#!/usr/bin/env bash

USER=vagrant
PASS=vagrant
DB=gis

echo '##############################'
echo '##### Adding Ubuntu user #####'
echo '##############################'

# Need to figure out how to make this work.
# Adding the password flag -p when creating the user is not secure.
#sudo useradd -m ${USER}
#sudo passwd ${USER} < ${PASS}
useradd -m ${USER} -p ${PASS}

echo '##############################'
echo '##### Adding postgres user ###'
echo '##############################'

cat << EOF | su - postgres -c psql
CREATE USER ${USER} WITH SUPERUSER PASSWORD '${PASS}';
EOF

cat << EOF | su - postgres
createdb -E UTF8 -O ${USER} ${DB}
EOF

cat << EOF | su - postgres -c "psql -d ${DB}"
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO ${USER};
ALTER TABLE spatial_ref_sys OWNER TO ${USER};
EOF

echo '##############################'
echo '##### Stylesheet config ######'
echo '##############################'


if [[ ! -d /vagrant/data ]]; then
  mkdir -p /vagrant/data
fi
cd /vagrant/data/

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
sudo chown ${USER} ${STYLEDIR}

su - ${USER}

cd ${STYLEDIR}

if [[ ! -d osm-bright-master ]]; then
  unzip /vagrant/data/zips/osm-bright-master.zip
fi

if [[ ! -d osm-bright-master/shp ]]; then
  mkdir osm-bright-master/shp
fi

cd osm-bright-master/shp

if [[ ! -f simplified-land-polygons-complete-3857/simplified-land-polygons.shp ]]; then
  unzip /vagrant/data/zips/simplified-land-polygons-complete-3857.zip
fi

if [[ ! -f land-polygons-split-3857/land-polygons.shp ]]; then
  unzip /vagrant/data/zips/land-polygons-split-3857.zip
fi

if [[ ! -f ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp ]]; then
  unzip -d ne_10m_populated_places_simple /vagrant/data/zips/ne_10m_populated_places_simple.zip
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
