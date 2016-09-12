require 'vagrant.rb'

Vagrant.configure(2) do |config|
  enable_cluster = ENV['ENABLE_CLUSTER']

  # Handle local proxy settings
  if Vagrant.has_plugin?('vagrant-proxyconf')
    config.proxy.http = ENV['http_proxy'] if ENV['http_proxy']
    config.proxy.https = ENV['https_proxy'] if ENV['https_proxy']
    if ENV['no_proxy']
      local_no_proxy = ',192.168.12.90,192.168.10.4,192.168.10.5,192.168.10.6,192.168.10.7,192.168.10.8,192.168.10.69'
      config.proxy.no_proxy = ENV['no_proxy'] + local_no_proxy
    end

    # config.proxy.http = 'http://proxy.intern.est.fujitsu.com:8080'
    # config.proxy.https = 'https://proxy.intern.est.fujitsu.com:8080'
    # config.proxy.no_proxy = '127.0.0.1,localhost,192.168.12.90,192.168.10.4,192.168.10.5'
  end

  config.timezone.value = :host if Vagrant.has_plugin?('vagrant-timezone')

  config.vm.define 'master' do |master|
    master.vm.hostname = 'master'
    master.vm.box = 'clear-centos7'
    master.vm.network :private_network, ip: '192.168.12.90'
    master.vm.provider 'virtualbox' do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'ansible-master.yml'
    end
  end

  config.vm.define 'openstack' do |openstack|
    openstack.vm.hostname = 'openstack.cmm'
    openstack.vm.box = 'devstack-centos7-liberty'
    openstack.vm.provision :hosts do |provision|
      provision.add_localhost_hostnames = false
      provision.add_host '192.168.10.4', ['monasca.cmm', 'monasca']
      if enable_cluster == '1'
        provision.add_host '192.168.10.6', ['exNode1.cmm', 'exNode1', 'ex_node_1']
        provision.add_host '192.168.10.7', ['exNode2.cmm', 'exNode2', 'ex_node_2']
        provision.add_host '192.168.10.8', ['exNode3.cmm', 'exNode3', 'ex_node_3']
      end
    end
    openstack.vm.network :private_network, ip: '192.168.10.5'
    openstack.vm.provider 'virtualbox' do |vb|
      vb.memory = 6192
      vb.cpus = 2
    end
  end

  config.vm.define 'monasca' do |monasca|
    monasca.vm.hostname = 'monasca.cmm'
    monasca.vm.box = 'clear-centos7'
    monasca.vm.provision :hosts do |provision|
      provision.add_localhost_hostnames = false
      provision.add_host '192.168.10.4', ['monasca.cmm', 'monasca']
      provision.add_host '192.168.10.5', ['openstack.cmm', 'openstack']
      if enable_cluster == '1'
        provision.add_host '192.168.10.6', ['exNode1.cmm', 'exNode1', 'ex_node_1']
        provision.add_host '192.168.10.7', ['exNode2.cmm', 'exNode2', 'ex_node_2']
        provision.add_host '192.168.10.8', ['exNode3.cmm', 'exNode3', 'ex_node_3']
      end
    end
    monasca.vm.network :private_network, ip: '192.168.10.4'
    monasca.vm.provider 'virtualbox' do |vb|
      if enable_cluster == '1'
        vb.memory = 2048
        vb.cpus = 2
      else
        vb.memory = 6192
        vb.cpus = 2
      end
    end
  end

  if enable_cluster == '1'
    # extra nodes for cluster configuration
    config.vm.define 'ex_node_1' do |ds|
      ds.vm.hostname = 'exNode1.cmm'
      ds.vm.box = 'clear-centos7'
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        provision.add_host '192.168.10.4', ['monasca.cmm', 'monasca']
        provision.add_host '192.168.10.5', ['openstack.cmm', 'openstack']
        provision.add_host '192.168.10.6', ['exNode1.cmm', 'exNode1', 'ex_node_1']
        provision.add_host '192.168.10.7', ['exNode2.cmm', 'exNode2', 'ex_node_2']
        provision.add_host '192.168.10.8', ['exNode3.cmm', 'exNode3', 'ex_node_3']
      end
      ds.vm.network :private_network, ip: '192.168.10.6'
      ds.vm.provider 'virtualbox' do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
    end

    config.vm.define 'ex_node_2' do |ds|
      ds.vm.hostname = 'exNode2.cmm'
      ds.vm.box = 'clear-centos7'
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        provision.add_host '192.168.10.4', ['monasca.cmm', 'monasca']
        provision.add_host '192.168.10.5', ['openstack.cmm', 'openstack']
        provision.add_host '192.168.10.6', ['exNode1.cmm', 'exNode1', 'ex_node_1']
        provision.add_host '192.168.10.7', ['exNode2.cmm', 'exNode2', 'ex_node_2']
        provision.add_host '192.168.10.8', ['exNode3.cmm', 'exNode3', 'ex_node_3']
      end
      ds.vm.network :private_network, ip: '192.168.10.7'
      ds.vm.provider 'virtualbox' do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
    end

    config.vm.define 'ex_node_3' do |ds|
      ds.vm.hostname = 'exNode3.cmm'
      ds.vm.box = 'clear-centos7'
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        provision.add_host '192.168.10.4', ['monasca.cmm', 'monasca']
        provision.add_host '192.168.10.5', ['openstack.cmm', 'openstack']
        provision.add_host '192.168.10.6', ['exNode1.cmm', 'exNode1', 'ex_node_1']
        provision.add_host '192.168.10.7', ['exNode2.cmm', 'exNode2', 'ex_node_2']
        provision.add_host '192.168.10.8', ['exNode3.cmm', 'exNode3', 'ex_node_3']
      end
      ds.vm.network :private_network, ip: '192.168.10.8'
      ds.vm.provider 'virtualbox' do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
    end
  end
end
