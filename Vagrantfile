# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/xenial64"
  #config.vm.define "concoursevm"
  config.vm.network "private_network", ip: "192.168.50.150"

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "tests/simple/simple.yml"
    ansible.groups = {
      "concourse-web" => ["default"],
      "concourse-worker" => ["default"],
      }
  end
end
