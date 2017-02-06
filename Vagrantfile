# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/centos-7.2"
  config.ssh.forward_agent = true

  config.vm.define "vagrant" do |host|
    host.vm.hostname = "vagrant"
    host.vm.network "private_network", ip: "192.168.33.60"
    host.vm.provision "shell", path: "provision.sh"
  end

end
