#!/usr/bin/env bash

GISUSER=maddoxw
DB=gis

PG_VERSION=`pg_config --version | sed 's/[^0-9.]*\([0-9][.][0-9]\)[.][0-9]*/\1/'`
PG_SOURCE_DIR="/home/${GISUSER}/git/OSM_tile_server/data/mods"
PG_SOURCE_CONF="postgresql${PG_VERSION}-before.conf"
PG_TARGET_DIR="/etc/postgresql/${PG_VERSION}/main"
PG_TARGET_CONF="postgresql.conf"
PG_CONF=${PG_TARGET_DIR}/${PG_TARGET_CONF}

# backup
if [ -f ${PG_CONF} ] && [ ! -f ${PG_CONF}.orig ]; then
    cp ${PG_CONF} ${PG_CONF}.orig
    chown postgres:postgres ${PG_CONF}.orig
    chmod 644 ${PG_CONF}.orig
fi
# copy new config
if [[ ! -f ${PG_TARGET_DIR}/${PG_SOURCE_CONF} ]]; then
    cp ${PG_SOURCE_DIR}/${PG_SOURCE_CONF} ${PG_TARGET_DIR}/${PG_SOURCE_CONF}
    chown postgres:postgres ${PG_TARGET_DIR}/${PG_SOURCE_CONF}
    chmod 644 ${PG_TARGET_DIR}/${PG_SOURCE_CONF}
fi
# remove link to config if it exists.
rm -f ${PG_CONF}
# link config
ln -s ${PG_TARGET_DIR}/${PG_SOURCE_CONF} ${PG_CONF}
chown postgres:postgres ${PG_CONF}
chmod 644 ${PG_CONF}

service postgresql restart

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

