#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [[ ! -d ~/src ]]; then
  mkdir ~/src
fi

cd ~/src
if [ -e osm2pgsql ]; then 
  cd osm2pgsql
  git pull
else
  git clone https://github.com/openstreetmap/osm2pgsql.git
  cd osm2pgsql
fi
if [[ ! -d build ]]; then
  mkdir build
fi
cd build
cmake ..
make -j 8
sudo make install

sudo mkdir -p /tmp/psql-tablespace
sudo /bin/chown postgres.postgres /tmp/psql-tablespace
psql -c "CREATE TABLESPACE tablespacetest LOCATION '/tmp/psql-tablespace'" postgres

cd tests
make -j 4
cd ../
make test

cd ../
sudo cp install-postgis-osm-user.sh /usr/bin/
sudo cp install-postgis-osm-db.sh /usr/bin/


cd ~/src
if [ -e mapnik ]; then 
  cd mapnik
  git pull
else
  git clone https://github.com/mapnik/mapnik.git
  cd mapnik
fi
git submodule update --init
git branch 2.2 origin/2.2.x
git checkout 2.2
python scons/scons.py configure INPUT_PLUGINS=all OPTIMIZATION=3 SYSTEM_FONTS=/usr/share/fonts/truetype/
make -j 8
sudo make install
sudo ldconfig


cd ~/src
if [ -e mod_tile ]; then 
  cd mod_tile
  git pull
else
  git clone https://github.com/openstreetmap/mod_tile.git
  cd mod_tile
fi
./autogen.sh
./configure
make -j 8
sudo make install
sudo make install-mod_tile
sudo ldconfig
cd ../
sudo touch /usr/bin/openstreetmap-tiles-update-expire


cd ~/src
if [ -e osmosis ]; then 
  cd osmosis
  git pull
else
  git clone https://github.com/openstreetmap/osmosis.git
  cd osmosis
fi
./gradlew assemble