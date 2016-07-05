#!/usr/bin/env bash

GISUSER=maddoxw
SRCDIR=/home/${GISUSER}/git/OSM_tile_server

DB=gis

# PG_VERSION=`pg_config --version | sed 's/[^0-9.]*\([0-9][.][0-9]\)[.][0-9]*/\1/'`
# PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
#
# if [[ ! -f ${PG_CONF}.orig ]]; then
#     cp ${PG_CONF} ${PG_CONF}.orig
# fi
# cp ${SRCDIR}/data/mods/postgresql${PG_VERSION}.conf ${PG_CONF}

cat << EOF | su - postgres -c psql
DROP DATABASE IF EXISTS ${DB};
CREATE DATABASE ${DB} ENCODING 'UTF8' OWNER ${GISUSER};
\c ${DB}
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
ALTER TABLE geometry_columns OWNER TO ${GISUSER};
ALTER TABLE spatial_ref_sys OWNER TO ${GISUSER};
EOF

# FLATNODESPATH=/media/OSM040/flat_nodes
# mkdir -p ${FLATNODESPATH}
# chown ${GISUSER}:${GISUSER} ${FLATNODESPATH}
# if [[ -f ${FLATNODESPATH}/planet.cache ]]; then
#     rm -rf ${FLATNODESPATH}/planet.cache
# fi

# PGXLOGPATH=/media/OSM070
# mkdir -p ${PGXLOGPATH}
# if [[ ! -L /var/lib/postgresql/${PG_VERSION}/main/pg_xlog ]]; then
#     cp -rf /var/lib/postgresql/${PG_VERSION}/main/pg_xlog ${PGXLOGPATH}
#     rm -rf /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
#     chown -R postgres:postgres ${PGXLOGPATH}
#     ln -s ${PGXLOGPATH}/pg_xlog /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
#     chown -R postgres:postgres /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
#     chmod 700 /var/lib/postgresql/${PG_VERSION}/main/pg_xlog
# fi

TBLSPC=main_data
SDBTBLSPCPATH=/media/OSM_${TBLSPC}
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

TBLSPC=main_index
SDBTBLSPCPATH=/media/OSM_${TBLSPC}
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

TBLSPC=slim_data
SDBTBLSPCPATH=/media/OSM_${TBLSPC}
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

TBLSPC=slim_index
SDBTBLSPCPATH=/media/OSM_${TBLSPC}
TBLSPCPATH=${SDBTBLSPCPATH}/${TBLSPC}
mkdir -p ${TBLSPCPATH}
chown postgres:postgres ${TBLSPCPATH}
cat << EOF | su - postgres -c psql
DROP TABLESPACE IF EXISTS ${TBLSPC};
CREATE TABLESPACE ${TBLSPC} OWNER ${GISUSER} LOCATION '${TBLSPCPATH}';
EOF

service postgresql restart