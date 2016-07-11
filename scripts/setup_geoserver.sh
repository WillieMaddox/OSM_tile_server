#!/usr/bin/env bash

#######################################################################
# Install the geoserver binary (i.e. not the war and not from source) #
#######################################################################

# Set the version of geoserver you want to download/use.
GSV="2.9.0"

# Set this to where you want your geoserver root directory to live.
# If you choose somewhere in your home directory you don't have to dick around with permissions.
GSP="${HOME}/src"

GSR="geoserver-${GSV}"
GSH="${GSP}/${GSR}"
GSZ="${GSR}-bin.zip"
GST="${HOME}/Downloads/${GSZ}"

if [[ ! -f ${GST} ]]; then
    GSS="https://sourceforge.net/projects/geoserver/files/GeoServer/${GSV}/${GSZ}/download"
    wget ${GSS} -O ${GST}
fi

unzip -d ${GSP} ${GST}

if [[ ! $GEOSERVER_HOME ]]; then
    echo "export GEOSERVER_HOME=${GSH}" >> ~/.bashrc
    . ~/.bashrc
fi

cd $GEOSERVER_HOME/bin
sh startup.sh