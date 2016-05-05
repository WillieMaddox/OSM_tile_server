#!/usr/bin/env bash

GISUSER=vagrant
DB=gis

PG_VERSION=`pg_config --version | sed 's/[^0-9.]*\([0-9][.][0-9]\)[.][0-9]*/\1/'`
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"

if [[ ! -f ${PG_CONF}.orig ]]; then
    cp ${PG_CONF} ${PG_CONF}.orig
fi
cp /vagrant/data/mods/postgresql${PG_VERSION}.conf ${PG_CONF}

cat << EOF | su - postgres -c psql
DROP DATABASE IF EXISTS ${DB};
CREATE DATABASE ${DB} ENCODING 'UTF8' OWNER ${GISUSER};
\c ${DB}
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO ${GISUSER};
ALTER TABLE spatial_ref_sys OWNER TO ${GISUSER};
EOF

FLATNODESPATH=/media/${DEV}2/flat_nodes
mkdir -p ${FLATNODESPATH}
chown ${GISUSER}:${GISUSER} ${FLATNODESPATH}
if [[ -f ${FLATNODESPATH}/planet.cache ]]; then
    rm -rf ${FLATNODESPATH}/planet.cache
fi

NIDS=(1 2 3 4)
DEV=sdc

SDBTBLSPCPATH=/media/${DEV}1
TBLSPC=main_data
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SDBTBLSPCPATH=/media/${DEV}2
TBLSPC=main_idx
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SDBTBLSPCPATH=/media/${DEV}3
TBLSPC=slim_data
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

SDBTBLSPCPATH=/media/${DEV}4
TBLSPC=slim_idx
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF
