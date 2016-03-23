# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  if Vagrant.has_plugin?("vagrant-timezone")
    config.timezone.value = "US/Central"
  end

  config.vm.define "osm" do |osm|
    osm.vm.box = "ubuntu-trusty64-osm120"
    osm.vm.hostname = "osm"
    osm.vm.network "private_network", ip: "172.16.5.120"
    osm.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    osm.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: true
    osm.vm.synced_folder "/media/Borg_LS/osm_data", "/osm_data", :nfs => true,  :mount_options => ['nolock,vers=3,tcp,noatime,clientaddr=172.16.5.120']

    osm.vm.provider "virtualbox" do |vb|
      vb.cpus = 8
      vb.memory = 64000
    end

    osm.bindfs.bind_folder "/osm_data", "/osm_nfs",
      :owner => "postgres",
      :group => "postgres",
#       :perms => "u=rwx:g=rwx:o=rwx",
      :perms => "u=rwx:g=r:o=r",
#       :'create-with-perms' => "u=rwx:g=rwx:o=rwx",
      :'create-with-perms' => "u=rwx:g=r:o=r",
      :'create-as-user' => true
#       :'chown-ignore' => true,
#       :'chgrp-ignore' => true,
#       :'chmod-ignore' => true

#     osm.vm.provision :shell, :path => "install.sh"
#     osm.vm.provision :shell, :path => "setup.sh", :privileged => false
    osm.vm.provision :shell, :path => "setup2.sh"
  end
end
