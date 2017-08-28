# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.define 'vagrantci' do |vagrantci|
  end

  config.vm.network "private_network", ip: '192.168.50.150'

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'test/integration/simple/simple.yml'
    ansible.groups = {
      "concourse-web" => ["vagrantci"],
      "concourse-worker" => ["vagrantci"],
      }
  end
end
