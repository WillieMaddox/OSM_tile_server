#!/usr/bin/env bash

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
make -j 4
make install

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
make -j 4
make install
ldconfig


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
make -j 4
make install
make install-mod_tile
ldconfig