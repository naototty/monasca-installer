require 'vagrant.rb'

Vagrant.configure(2) do |config|

  enable_cluster = ENV["ENABLE_CLUSTER"]

  # Handle local proxy settings
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if ENV["http_proxy"]
      config.proxy.http = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      config.proxy.https = ENV["https_proxy"]
    end
    if ENV["no_proxy"]
      local_no_proxy = ",192.168.12.90,192.168.10.4,192.168.10.5,192.168.10.6,192.168.10.7,192.168.10.8"
      config.proxy.no_proxy = ENV["no_proxy"] + local_no_proxy
    end

    #config.proxy.http = "http://proxy.intern.est.fujitsu.com:8080"
    #config.proxy.https = "https://proxy.intern.est.fujitsu.com:8080"
    #config.proxy.no_proxy = "127.0.0.1,localhost,192.168.12.90,192.168.10.4,192.168.10.5"
  end

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "clear-centos7"
    master.vm.network :private_network, ip: "192.168.12.90"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible-master.yml"
    end
  end

  config.vm.define "openstack" do |openstack|
    openstack.vm.hostname = "openstack"
    openstack.vm.box = "monasca-devstack-centos"
    openstack.vm.network :private_network, ip: "192.168.10.5"
    openstack.vm.provider "virtualbox" do |vb|
      vb.memory = 6192
      vb.cpus = 2
    end
  end

  config.vm.define "monasca" do |monasca|
    monasca.vm.hostname = "monasca"
    monasca.vm.box = "clear-centos7"
    monasca.vm.network :private_network, ip: "192.168.10.4"
    monasca.vm.provider "virtualbox" do |vb|
      vb.memory = 6192
      vb.cpus = 2
    end
  end

  if enable_cluster == "1"
    # extra nodes for cluster configuration
    config.vm.define "ex_node_1" do |ds|
      ds.vm.hostname = "exNode1"
      ds.vm.box = "clear-centos7"
      ds.vm.network :private_network, ip: "192.168.10.6"
      ds.vm.provider "virtualbox" do |vb|
        vb.memory = 2024
        vb.cpus = 1
      end
    end

    config.vm.define "ex_node_2" do |ds|
      ds.vm.hostname = "exNode2"
      ds.vm.box = "clear-centos7"
      ds.vm.network :private_network, ip: "192.168.10.7"
      ds.vm.provider "virtualbox" do |vb|
        vb.memory = 2024
        vb.cpus = 1
      end
    end

    config.vm.define "ex_node_3" do |ds|
      ds.vm.hostname = "exNode3"
      ds.vm.box = "clear-centos7"
      ds.vm.network :private_network, ip: "192.168.10.8"
      ds.vm.provider "virtualbox" do |vb|
        vb.memory = 2024
        vb.cpus = 1
      end
    end
  end

end
