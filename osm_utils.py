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
from datetime import datetime
from datetime import timedelta

from matplotlib.dates import date2num
import matplotlib.pyplot as plt


def dstat_format_func(keys, x):
    if "time" in keys[1]:
        # 30-04 12:47:38
        dt = datetime.strptime(x, "%d-%m %H:%M:%S")
        dt = dt.replace(year=2016)
        return dt
    elif "read" in keys[1]:
        return float(x)/1048576.0
    elif "writ" in keys[1]:
        return float(x)/1048576.0
    elif "memory usage" in keys[0]:
        if "buff" in keys[1]:
            return float(x)/1024.0/1024.0
        else:
            return float(x)/1024.0/1024.0/1024.0
    else:
        return float(x)


def read_dstat(filename):
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
        for hh, h1 in zip(header0, header1):
            if hh != '':
                h0 = hh
                if h0 not in dstatdict:
                    dstatdict[h0] = {}
                if h1 not in dstatdict[h0]:
                    dstatdict[h0][h1] = []
            else:
                dstatdict[h0][h1] = []
            headers.append([h0, h1])

        for row in reader:
            for i, col in enumerate(row):
                dstatdict[headers[i][0]][headers[i][1]].append(dstat_format_func(headers[i], col))
    return dstatdict


def read_df(filename):
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
                if 'datetime' not in dfdict:
                    dfdict['datetime'] = [dt]
                else:
                    dfdict['datetime'].append(dt)
    return dfdict


def read_du(filename):
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
                        dudict[headers[i]].append(dt)
                    else:
                        dudict[headers[i]].append(float(col)/1024.0/1024.0)
    return dudict


def read_osm2pgsql(filename):
    osm2pgsqldict = {}
    with open(filename) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        row = reader.next()
        dt = datetime.strptime(row[1], "%a %b %d %H:%M:%S %Z %Y")
        for row in reader:
            if row[0].startswith('#'):
                continue
            dt += timedelta(seconds=float(row[1]))
            osm2pgsqldict[row[0]] = dt
    return osm2pgsqldict


run_idx = 'benchmarks/f01'
dstat_file = run_idx+'_dstat.txt'
dstat_dict = read_dstat(dstat_file)
dstat_dates = date2num(dstat_dict['system']['time'])

du_file = run_idx+'_du.txt'
du_dict = read_du(du_file)
du_dates = date2num(du_dict['time'])

df_file = run_idx+'_df.txt'
df_dict = read_df(df_file)
df_dates = date2num(df_dict['datetime'])

osm2pgsql_file = run_idx+'_osm2pgsql.txt'
osm2pgsql_dict = read_osm2pgsql(osm2pgsql_file)

ymaxs = [250, 250, 250, 250, 250, 128, 900, 100, 15, 25]
fig, ax = plt.subplots(len(ymaxs), sharex=True, figsize=(16, 10))

ax[0].plot_date(df_dates, df_dict['/dev/sdb8'], 'r-', lw=1)
ax[0].plot_date(df_dates, df_dict['/dev/sdb6'], 'g-', lw=2)

ax[1].plot_date(dstat_dates, dstat_dict['dsk/sdc1']['writ'], 'y-')
ax[1].plot_date(dstat_dates, dstat_dict['dsk/sdc1']['read'], 'b-')
ax[1].plot_date(df_dates, df_dict['/dev/sdc1'], 'g-', lw=2)
ax[1].plot_date(du_dates, du_dict['main_data'], 'k--', lw=2)

ax[2].plot_date(dstat_dates, dstat_dict['dsk/sdc2']['writ'], 'y-')
ax[2].plot_date(dstat_dates, dstat_dict['dsk/sdc2']['read'], 'b-')
ax[2].plot_date(df_dates, df_dict['/dev/sdc2'], 'g-', lw=2)
ax[2].plot_date(du_dates, du_dict['main_idx'], 'k--', lw=2)

ax[3].plot_date(dstat_dates, dstat_dict['dsk/sdc3']['writ'], 'y-')
ax[3].plot_date(dstat_dates, dstat_dict['dsk/sdc3']['read'], 'b-')
ax[3].plot_date(df_dates, df_dict['/dev/sdc3'], 'g-', lw=2)
ax[3].plot_date(du_dates, du_dict['slim_data'], 'k--', lw=2)

ax[4].plot_date(dstat_dates, dstat_dict['dsk/sdc4']['writ'], 'y-')
ax[4].plot_date(dstat_dates, dstat_dict['dsk/sdc4']['read'], 'b-')
ax[4].plot_date(df_dates, df_dict['/dev/sdc4'], 'g-', lw=2)
ax[4].plot_date(du_dates, du_dict['slim_idx'], 'k--', lw=2)

ax[5].plot_date(dstat_dates, dstat_dict['memory usage']['used'], 'g-', lw=2)
ax[5].plot_date(dstat_dates, dstat_dict['memory usage']['cach'], 'b-', lw=2)
ax[5].plot_date(dstat_dates, dstat_dict['memory usage']['free'], 'k-', lw=2)

ax[6].plot_date(dstat_dates, dstat_dict['memory usage']['buff'], '-')

ax[7].plot_date(dstat_dates, dstat_dict['total cpu usage']['usr'], '-')
ax[7].plot_date(dstat_dates, dstat_dict['total cpu usage']['sys'], '-')

ax[8].plot_date(dstat_dates, dstat_dict['total cpu usage']['wai'], '-', color='r')
ax[8].plot_date(dstat_dates, dstat_dict['total cpu usage']['hiq'], '-')
ax[8].plot_date(dstat_dates, dstat_dict['total cpu usage']['siq'], '-')

ax[9].plot_date(dstat_dates, dstat_dict['load avg']['1m'], '-')
ax[9].plot_date(dstat_dates, dstat_dict['load avg']['5m'], '-')
ax[9].plot_date(dstat_dates, dstat_dict['load avg']['15m'], '-')

for i, ymax in enumerate(ymaxs):
    for key, value in osm2pgsql_dict.iteritems():
        ax[i].vlines(value, 0, ymax, label=key)
        ax[i].set_ylim([0, ymax])

fig.subplots_adjust(hspace=0)
plt.setp([a.get_xticklabels() for a in fig.axes[:-1]], visible=False)
plt.show()
