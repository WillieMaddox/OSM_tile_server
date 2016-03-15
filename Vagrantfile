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
    osm.vm.box = "ubuntu/trusty64"
    osm.vm.hostname = "osm"
    osm.vm.network "private_network", ip:"172.16.5.120"
    osm.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    osm.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: true
    #osm.vm.synced_folder "../data", "/vagrant_data"
    osm.vm.provider "virtualbox" do |vb|
      vb.cpus = 8
      vb.memory = 32768
    end

    #osm.vm.provision :shell, :path => "install.sh"
    #osm.vm.provision :shell, :privileged => false, :path => "setup.sh"
    #osm.vm.provision :shell, :path => "setup2.sh"
  end
end
