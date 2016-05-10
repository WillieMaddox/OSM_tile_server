#!/usr/bin/python

"""
date >> df.txt
df | sort | grep /dev/sd >> df.txt

Fri Apr 29 21:47:35 CDT 2016
/dev/sda1      1922728752 263520744 1561515952  15% /media/Borg_LS
/dev/sdb6       351784100 238139416   95752032  72% /
/dev/sdb7        40185208     49036   38071788   1% /media/OSM040
/dev/sdb8        71897424  24760156   43461980  37% /media/OSM070
/dev/sdc1       302248384     64352  286807648   1% /media/OSM300
/dev/sdc2       151058636     60872  143301380   1% /media/OSM150
/dev/sdc3       201454560     60692  191137484   1% /media/OSM200
/dev/sdc4       329221796     68304  312406948   1% /media/OSM325

"""

import csv
import os
from datetime import datetime
from datetime import timedelta

from matplotlib.dates import date2num
import matplotlib.pyplot as plt


def dstat_format_func(keys, x, st=None):
    if "time" in keys[1]:
        # 30-04 12:47:38
        assert st is not None
        dt = datetime.strptime(x, "%d-%m %H:%M:%S")
        dt = dt.replace(year=2016)
        dt = dt - st
        return dt.total_seconds()
    elif "read" in keys[1]:
        return float(x)/1024.0/1024.0
    elif "writ" in keys[1]:
        return float(x)/1024.0/1024.0
    elif "swap" in keys[0]:
        return float(x)/1024.0/1024.0/1024.0
    elif "paging" in keys[0]:
        return float(x)/1024.0/1024.0
    elif "memory usage" in keys[0]:
        if "buff" in keys[1]:
            return float(x)/1024.0/1024.0
        else:
            return float(x)/1024.0/1024.0/1024.0
    else:
        return float(x)


def read_dstat(filename, start_time):
    dstatdict = {}
    with open(filename) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')

        # Skip the first five lines
        reader.next()
        reader.next()
        reader.next()
        reader.next()
        reader.next()

        # lines 6 and 7 contain the header information
        header0 = reader.next()
        header1 = reader.next()
        headers = []
        for i, (hh, h1) in enumerate(zip(header0, header1)):
            if hh != '':
                h0 = hh
                if h0 not in dstatdict:
                    dstatdict[h0] = {}
                if h1 not in dstatdict[h0]:
                    dstatdict[h0][h1] = []
            else:
                dstatdict[h0][h1] = []
            if h1 == "time":
                time_col = i
            headers.append([h0, h1])

        for row in reader:
            for i, col in enumerate(row):
                if i == time_col:
                    dstatdict[headers[i][0]][headers[i][1]].append(dstat_format_func(headers[i], col, st=start_time))
                else:
                    dstatdict[headers[i][0]][headers[i][1]].append(dstat_format_func(headers[i], col))
    return dstatdict


def read_df(filename, start_time):
    dfdict = {}
    startsize = -1
    with open(filename) as ifs:
        for line in ifs:
            line = line.strip()
            if line.startswith('/'):
                cols = line.split()

                if cols[0] not in dfdict:
                    dfdict[cols[0]] = []

                if cols[5] == '/':
                    if startsize < 0:
                        startsize = float(cols[2])
                    col = float(cols[2]) - startsize
                else:
                    col = float(cols[2])

                dfdict[cols[0]].append(float(col)/1024.0/1024.0)
            else:
                dt = datetime.strptime(line, "%a %b %d %H:%M:%S %Z %Y")
                dt = dt - start_time
                if 'datetime' not in dfdict:
                    dfdict['datetime'] = [dt.total_seconds()]
                else:
                    dfdict['datetime'].append(dt.total_seconds())
    return dfdict


def read_du(filename, start_time):
    dudict = {}
    headers = []
    with open(filename) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        header = reader.next()
        for h in header:
            if h != '':
                headers.append(h)
                dudict[h] = []
        for row in reader:
            for i, col in enumerate(row):
                if col != '':
                    if headers[i] == 'time':
                        dt = datetime.strptime(col, "%a %b %d %H:%M:%S %Z %Y")
                        dt = dt - start_time
                        dudict[headers[i]].append(dt.total_seconds())
                    else:
                        dudict[headers[i]].append(float(col)/1024.0/1024.0)
    return dudict


def read_osm2pgsql(filename):
    osm2pgsqldict = {}
    with open(filename) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        row = reader.next()
        assert row[0].lower() == 'i_flag'
        has_parallel_indexing = row[1].lower() == 'true'
        row = reader.next()
        dt0 = datetime.strptime(row[1], "%a %b %d %H:%M:%S %Z %Y")
        osm2pgsqldict[row[0]] = dt0
        dt = dt0

        for _ in range(4):
            row = reader.next()
            dt += timedelta(seconds=float(row[1]))
            osm2pgsqldict[row[0]] = dt

        if has_parallel_indexing:
            for row in reader:
                dt += timedelta(seconds=float(row[1]))
                osm2pgsqldict[row[0]] = dt
            osm2pgsqldict.pop('result', None)
        else:
            temp_dict = {}
            for row in reader:
                if row[0].startswith('#'):
                    continue
                temp_dict[row[0]] = float(row[1])
            osm2pgsqldict['result'] = dt0 + timedelta(seconds=temp_dict['result'])
            osm2pgsqldict['planet_osm_rels'] = osm2pgsqldict['result'] - timedelta(seconds=temp_dict['planet_osm_rels'])
            osm2pgsqldict['planet_osm_ways'] = osm2pgsqldict['planet_osm_rels'] - timedelta(seconds=temp_dict['planet_osm_ways'])
    return osm2pgsqldict


run_idx = 'benchmarks/f07'

osm2pgsql_file = run_idx+'/osm2pgsql.txt'
osm2pgsql_dict = read_osm2pgsql(osm2pgsql_file)
start_time = osm2pgsql_dict['Start time']

dstat_file = run_idx+'/dstat.txt'
if os.path.exists(dstat_file):
    dstat_dict = read_dstat(dstat_file, start_time)
    # dstat_dates = date2num(dstat_dict['system']['time'])
else:
    dstat_dict = None

du_file = run_idx+'/du.txt'
if os.path.exists(du_file):
    du_dict = read_du(du_file, start_time)
    # du_dates = date2num(du_dict['time'])
else:
    du_dict = None

df_file = run_idx+'/df.txt'
if os.path.exists(df_file):
    df_dict = read_df(df_file, start_time)
    # df_dates = date2num(df_dict['datetime'])
else:
    df_dict = None

ymaxs = [250, 500, 250, 250, 250, 128, 100, 16, 20]
fig, ax = plt.subplots(len(ymaxs), sharex=True, figsize=(16, 10))

if df_dict is not None:
    ax[0].plot(df_dict['datetime'], df_dict['/dev/sdb8'], 'r-', lw=1)
    ax[0].plot(df_dict['datetime'], df_dict['/dev/sdb6'], 'g-', lw=2)

if dstat_dict is not None:
    if 'dsk/sdc1' in dstat_dict:
        ax[1].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc1']['writ'], 'y-')
        ax[1].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc1']['read'], 'b-')
if df_dict is not None:
    if 'dsk/sdc1' in dstat_dict:
        ax[1].plot(df_dict['datetime'], df_dict['/dev/sdc1'], 'g-', lw=2)
if du_dict is not None:
    ax[1].plot(du_dict['time'], du_dict['main_data'], 'k-', lw=2)

if dstat_dict is not None:
    if 'dsk/sdc2' in dstat_dict:
        ax[2].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc2']['writ'], 'y-')
        ax[2].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc2']['read'], 'b-')
if df_dict is not None:
    if 'dsk/sdc2' in dstat_dict:
        ax[2].plot(df_dict['datetime'], df_dict['/dev/sdc2'], 'g-', lw=2)
if du_dict is not None:
    ax[2].plot(du_dict['time'], du_dict['main_idx'], 'k-', lw=2)

if dstat_dict is not None:
    if 'dsk/sdc3' in dstat_dict:
        ax[3].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc3']['writ'], 'y-')
        ax[3].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc3']['read'], 'b-')
if df_dict is not None:
    if 'dsk/sdc3' in dstat_dict:
        ax[3].plot(df_dict['datetime'], df_dict['/dev/sdc3'], 'g-', lw=2)
if du_dict is not None:
    ax[3].plot(du_dict['time'], du_dict['slim_data'], 'k-', lw=2)

if dstat_dict is not None:
    if 'dsk/sdc4' in dstat_dict:
        ax[4].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc4']['writ'], 'y-')
        ax[4].plot(dstat_dict['system']['time'], dstat_dict['dsk/sdc4']['read'], 'b-')
if df_dict is not None:
    if 'dsk/sdc4' in dstat_dict:
        ax[4].plot(df_dict['datetime'], df_dict['/dev/sdc4'], 'g-', lw=2)
if du_dict is not None:
    ax[4].plot(du_dict['time'], du_dict['slim_idx'], 'k-', lw=2)

if dstat_dict is not None:
    ax[5].plot(dstat_dict['system']['time'], dstat_dict['memory usage']['used'], 'g-', lw=2)
    ax[5].plot(dstat_dict['system']['time'], dstat_dict['memory usage']['cach'], 'b-', lw=2)
    ax[5].plot(dstat_dict['system']['time'], dstat_dict['memory usage']['free'], 'k-', lw=2)

if dstat_dict is not None:
    ax[6].plot(dstat_dict['system']['time'], dstat_dict['total cpu usage']['usr'], '-')
    ax[6].plot(dstat_dict['system']['time'], dstat_dict['total cpu usage']['sys'], '-')

if dstat_dict is not None:
    if 'swap' in dstat_dict:
        ax[7].plot(dstat_dict['system']['time'], dstat_dict['swap']['used'], '-')

if dstat_dict is not None:
    if 'paging' in dstat_dict:
        ax[8].plot(dstat_dict['system']['time'], dstat_dict['paging']['out'], 'r-')
        ax[8].plot(dstat_dict['system']['time'], dstat_dict['paging']['in'], 'b-')

# ax[8].plot(dstat_dict['system']['time'], dstat_dict['memory usage']['buff'], '-')

# ax[9].plot(dstat_dict['system']['time'], dstat_dict['total cpu usage']['wai'], '-', color='r')
# ax[9].plot(dstat_dict['system']['time'], dstat_dict['total cpu usage']['hiq'], '-')
# ax[9].plot(dstat_dict['system']['time'], dstat_dict['total cpu usage']['siq'], '-')

# ax[10].plot(dstat_dict['system']['time'], dstat_dict['load avg']['1m'], '-')
# ax[10].plot(dstat_dict['system']['time'], dstat_dict['load avg']['5m'], '-')
# ax[10].plot(dstat_dict['system']['time'], dstat_dict['load avg']['15m'], '-')

for i, ymax in enumerate(ymaxs):
    for key, value in osm2pgsql_dict.iteritems():
        value = value - start_time
        ax[i].vlines(value.total_seconds(), 0, ymax, label=key)
        ax[i].set_ylim([0, ymax])
        ax[i].set_xlim([-300, 70000])

fig.subplots_adjust(hspace=0)
plt.setp([a.get_xticklabels() for a in fig.axes[:-1]], visible=False)
plt.show()
