Vagrant.configure(2) do |config|

  # Handle local proxy settings
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if ENV["http_proxy"]
      config.proxy.http = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      config.proxy.https = ENV["https_proxy"]
    end
    if ENV["no_proxy"]
      config.proxy.no_proxy = ENV["no_proxy"] + ",192.168.12.90,192.168.10.4,192.168.10.5"
    end
  end
  
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "clear-centos7"
    master.vm.network :private_network, ip: "192.168.12.90"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
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

end
