**Do Not Trust This ReadMe.  It Is Still In Work**

How to use vagrant to spin up your own OpenStreetMap (OSM) tile server.
##Introduction

This project uses PostgreSQL, PostGIS, osm2pgsql,
Mapnik, mod_tile, renderd, osmosis and others.
Luckily, you don't need to download/install these on your owm machine.
Vagrant handles all the package management.

One of the main problems people face when trying to use OSM in a vagrant environment is the IO speed of synced_folders.

Specifically, the IO speed of VirtualBox and VMWare is downright abysmal.

Some people have suggested that using NFS shares will drastically speedup IO.

Well, they're half right.

I spent a lot of time in the beginning of this project trying to mount synced_folders as NFS shares.

As it turns out, the speedup is only true for reads, not writes.

And if you plan on importing the whole OSM planet file into your database, you are certainly going to want fast writes.

If your vagrant box AND OSM database are destined to live on a
RAID 10 array, or a big (~ 1TB) SSD, then you probably won't
need to use synced_folders the way I am using them.

You'll want to create a separate VDI to use in place of synced_folders, especially if you plan on spreading your tablespaces across multiple drives.


##Dependencies
Vagrant/VirtualBox

##Monitoring and Profiling Tools
htop, df, free and dstat

##Usage
*Pre `up` instructions go here*
```
vagrant up
```
*Pre `provision` instructions go here*
```
vagrant provision
```
*Post `provision` instructions go here*
##TODO

Add render_list_geo.pl

Add links to osmosis docs in Apache

Rewrite mod_tile/slippymap.html using OL3

FINISH THIS README!!!!