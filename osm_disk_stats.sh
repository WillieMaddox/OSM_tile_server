#!/usr/bin/env bash

SLEEP=5
II=17280
NN=(0 1 2 3)
# DEVS=(OSM070 OSM300 OSM150 OSM200 OSM325)
# DEVS=(OSM070 OSM1000 OSM1000 OSM1000 OSM1000)
# DIRS=(pg_xlog main_data main_idx slim_data slim_idx)
DEVS=(OSM_main_data OSM_main_index OSM_slim_data OSM_slim_index)
DIRS=(main_data main_index slim_data slim_index)

rm -f du.txt
touch du.txt

rm -f df.txt
touch df.txt

printf "time," >> du.txt
for N in ${NN[@]}; do
    printf %s "${DIRS[$N]}," >> du.txt
done
echo '' >> du.txt

for ((I=0; I<=${II}; I++)); do
    printf %s "$(date)," >> du.txt
    for N in ${NN[@]}; do
        du /media/${DEVS[$N]}/${DIRS[$N]} | tail -1 | sed "s/\/.*//" | sed "s/\t/,/g" | tr -d '\n' >> du.txt
    done
    echo '' >> du.txt

    date >> df.txt
    df | sort | grep /dev/sd >> df.txt
    sleep ${SLEEP}
done
