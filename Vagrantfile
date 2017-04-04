require 'vagrant.rb'

Vagrant.configure(2) do |config|
  enable_cluster = ENV['ENABLE_CLUSTER']

  vms = {
    master:
      { ip: '192.168.12.90' },
    monasca:
      { ip: '192.168.10.4', fqdns: ['monasca.monasca', 'monasca'] },
    openstack:
      { ip: '192.168.10.5', fqdns: ['openstack.monasca', 'openstack'] },
    ex_node_1:
      { ip: '192.168.10.6', fqdns: ['exNode1.monasca', 'exNode1', 'ex_node_1'] },
    ex_node_2:
      { ip: '192.168.10.7', fqdns: ['exNode2.monasca', 'exNode2', 'ex_node_2'] },
    ex_node_3:
      { ip: '192.168.10.8', fqdns: ['exNode3.monasca', 'exNode3', 'ex_node_3'] },
  }

  virtual_ip = '192.168.10.69'

  ips_list = vms.keys.collect { |k| vms[k][:ip] }
  ips_string = ips_list.join(',') + ",#{virtual_ip}"

  # Handle local proxy settings
  if Vagrant.has_plugin?('vagrant-proxyconf')
    config.proxy.http = ENV['http_proxy'] if ENV['http_proxy']
    config.proxy.https = ENV['https_proxy'] if ENV['https_proxy']
    if ENV['no_proxy']
      local_no_proxy = ",#{ips_string}"
      config.proxy.no_proxy = ENV['no_proxy'] + local_no_proxy
    end

    # config.proxy.http = 'http://proxy.intern.est.fujitsu.com:8080'
    # config.proxy.https = 'https://proxy.intern.est.fujitsu.com:8080'
    # config.proxy.no_proxy = "127.0.0.1,localhost,#{ips_string}"
  end

  config.timezone.value = :host if Vagrant.has_plugin?('vagrant-timezone')

  config.vm.define 'master' do |master|
    master.vm.hostname = 'master'
    master.vm.box = 'clear-centos7'
    master.vm.network :private_network, ip: vms[:master][:ip]
    master.vm.provider 'virtualbox' do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'ansible-master.yml'
    end
    master.vbguest.no_install = true if Vagrant.has_plugin?('vagrant-vbguest')
  end

  config.vm.define 'openstack' do |openstack|
    openstack.vm.hostname = 'openstack.monasca'
    openstack.vm.box = 'devstack-centos7-liberty'
    openstack.vm.provision :hosts do |provision|
      provision.add_localhost_hostnames = false
      provision.add_host vms[:monasca][:ip], vms[:monasca][:fqdns]
      if enable_cluster == '1'
        provision.add_host vms[:ex_node_1][:ip], vms[:ex_node_1][:fqdns]
        provision.add_host vms[:ex_node_2][:ip], vms[:ex_node_2][:fqdns]
        provision.add_host vms[:ex_node_3][:ip], vms[:ex_node_3][:fqdns]
      end
    end
    openstack.vm.network :private_network, ip: vms[:openstack][:ip]
    openstack.vm.provider 'virtualbox' do |vb|
      vb.memory = 6192
      vb.cpus = 2
    end
    openstack.vbguest.no_install = true if Vagrant.has_plugin?('vagrant-vbguest')
  end

  config.vm.define 'monasca' do |monasca|
    monasca.vm.hostname = 'monasca.monasca'
    monasca.vm.box = 'clear-centos7'
    monasca.vm.provision :hosts do |provision|
      provision.add_localhost_hostnames = false
      provision.add_host vms[:monasca][:ip], vms[:monasca][:fqdns]
      provision.add_host vms[:openstack][:ip], vms[:openstack][:fqdns]
      if enable_cluster == '1'
        provision.add_host vms[:ex_node_1][:ip], vms[:ex_node_1][:fqdns]
        provision.add_host vms[:ex_node_2][:ip], vms[:ex_node_2][:fqdns]
        provision.add_host vms[:ex_node_3][:ip], vms[:ex_node_3][:fqdns]
      end
    end
    monasca.vm.network :private_network, ip: vms[:monasca][:ip]
    monasca.vm.provider 'virtualbox' do |vb|
      if enable_cluster == '1'
        vb.memory = 2048
        vb.cpus = 2
      else
        vb.memory = 6192
        vb.cpus = 2
      end
    end
    monasca.vbguest.no_install = true if Vagrant.has_plugin?('vagrant-vbguest')
  end

  if enable_cluster == '1'
    # extra nodes for cluster configuration
    config.vm.define 'ex_node_1' do |ds|
      ds.vm.hostname = 'exNode1.monasca'
      ds.vm.box = 'clear-centos7'
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        provision.add_host vms[:monasca][:ip], vms[:monasca][:fqdns]
        provision.add_host vms[:openstack][:ip], vms[:openstack][:fqdns]
        provision.add_host vms[:ex_node_1][:ip], vms[:ex_node_1][:fqdns]
        provision.add_host vms[:ex_node_2][:ip], vms[:ex_node_2][:fqdns]
        provision.add_host vms[:ex_node_3][:ip], vms[:ex_node_3][:fqdns]
      end
      ds.vm.network :private_network, ip: vms[:ex_node_1][:ip]
      ds.vm.provider 'virtualbox' do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
      ds.vbguest.no_install = true if Vagrant.has_plugin?('vagrant-vbguest')
    end

    config.vm.define 'ex_node_2' do |ds|
      ds.vm.hostname = 'exNode2.monasca'
      ds.vm.box = 'clear-centos7'
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        provision.add_host vms[:monasca][:ip], vms[:monasca][:fqdns]
        provision.add_host vms[:openstack][:ip], vms[:openstack][:fqdns]
        provision.add_host vms[:ex_node_1][:ip], vms[:ex_node_1][:fqdns]
        provision.add_host vms[:ex_node_2][:ip], vms[:ex_node_2][:fqdns]
        provision.add_host vms[:ex_node_3][:ip], vms[:ex_node_3][:fqdns]
      end
      ds.vm.network :private_network, ip: vms[:ex_node_2][:ip]
      ds.vm.provider 'virtualbox' do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
      ds.vbguest.no_install = true if Vagrant.has_plugin?('vagrant-vbguest')
    end

    config.vm.define 'ex_node_3' do |ds|
      ds.vm.hostname = 'exNode3.monasca'
      ds.vm.box = 'clear-centos7'
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        provision.add_host vms[:monasca][:ip], vms[:monasca][:fqdns]
        provision.add_host vms[:openstack][:ip], vms[:openstack][:fqdns]
        provision.add_host vms[:ex_node_1][:ip], vms[:ex_node_1][:fqdns]
        provision.add_host vms[:ex_node_2][:ip], vms[:ex_node_2][:fqdns]
        provision.add_host vms[:ex_node_3][:ip], vms[:ex_node_3][:fqdns]
      end
      ds.vm.network :private_network, ip: vms[:ex_node_3][:ip]
      ds.vm.provider 'virtualbox' do |vb|
        vb.memory = 4096
        vb.cpus = 2
      end
      ds.vbguest.no_install = true if Vagrant.has_plugin?('vagrant-vbguest')
    end
  end
end
