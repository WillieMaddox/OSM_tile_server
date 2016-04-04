# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

# disk = '/media/Borg_LS/VirtualBox VMs/OSM_tile_server_osm_1459229936301_28361/dstat-monitor.vdi'
disk = '/home/maddoxw/VirtualDrives/vssd96G.vdi'

Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = "US/Central"
  end

  config.vm.define "osm" do |osm|
    osm.vm.box = "OSM-Trusty64"
#     osm.vm.box = "ubuntu-trusty64-osm120"
    osm.vm.hostname = "osm"
    osm.vm.network "private_network", ip: "172.16.5.120"
    osm.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    osm.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: true

#     osm.vm.synced_folder '.', '/vagrant',
#       :nfs => true,
#       :mount_options => ['vers=4,tcp,fsc,actimeo=2'],
#       :linux__nfs_options => ['rw','no_subtree_check','all_squash','async']

    osm.vm.synced_folder "/home/maddoxw/osm_ssd", "/osm_ssd"
    osm.vm.synced_folder "/home/maddoxw/osm_ssd", "/osm_ssd_nfs",
      :nfs => true, :mount_options => ['fsc,vers=4,tcp,noatime,actimeo=2']

    osm.vm.synced_folder "/media/BLACK/osm_hdd", "/osm_hdd"
    osm.vm.synced_folder "/media/BLACK/osm_hdd", "/osm_hdd_nfs",
      :nfs => true, :mount_options => ['fsc,vers=4,tcp,noatime,actimeo=2']


#     osm.vm.synced_folder "/media/Borg_LS/test/osm2", "/osm2",
#       :nfs => true,
#       :mount_options => ['vers=4,tcp,fsc,actimeo=2'],
#       :linux__nfs_options => ['rw','no_subtree_check','all_squash','async']

#     osm.vm.synced_folder "/media/Borg_LS/test/osm3", "/osm3",
#       :nfs => true,
#       :mount_options => ['vers=3,nolock,tcp,noatime,fsc']

    osm.vm.provider "virtualbox" do |vb|
      host = RbConfig::CONFIG['host_os']

      # Give VM 1/4 system memory
      if host =~ /darwin/
        # sysctl returns Bytes and we need to convert to MB
        mem = `sysctl -n hw.memsize`.to_i / 1024
      elsif host =~ /linux/
        # meminfo shows KB and we need to convert to MB
        mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i
      elsif host =~ /mswin|mingw|cygwin/
        # Windows code via https://github.com/rdsubhas/vagrant-faster
        mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024
      end

      mem = mem / 1024 / 2
      vb.customize ["modifyvm", :id, "--memory", mem]
#       vb.memory = 64000
      vb.cpus = 8
      unless File.exist?(disk)
        vb.customize ['createhd', '--filename', disk, '--size', 96 * 1024]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk]
    end


#     osm.bindfs.bind_folder "/ssd_nfs", "/ssd_nfs",
#       :'force-user' => "postgres",
#       :'force-group' => "postgres",
#       :'perms' => "u=rwx:g=r:o=r",
#       :'create-with-perms' => "u=rwx:g=r:o=r",
#       :'create-as-user' => true,
#       :'multithreaded' => true

#     osm.bindfs.bind_folder "/hdd_nfs", "/hdd_nfs",
#       :'force-user' => "postgres",
#       :'force-group' => "postgres",
#       :'perms' => "u=rwx:g=r:o=r",
#       :'create-with-perms' => "u=rwx:g=r:o=r",
#       :'create-as-user' => true,
#       :'multithreaded' => true
# #       :'chown-ignore' => true,
# #       :'chgrp-ignore' => true,
# #       :'chmod-ignore' => true

    osm.vm.provision :shell, :path => "install.sh"
    osm.vm.provision :shell, :path => "setup_VHDs.sh"
    osm.vm.provision :shell, :path => "setup.sh", :privileged => false
    osm.vm.provision :shell, :path => "setup2.sh"
#     osm.vm.provision :shell, :path => "setup3.sh"
  end
end
