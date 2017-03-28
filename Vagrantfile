require "vagrant.rb"

Vagrant.configure(2) do |config|
  enable_cluster = ENV["ENABLE_CLUSTER"]

  vms = {
    'master' =>
      { 'ip' => {
        'normal_network' => '192.168.10.90',
        'admin_network' => '192.168.124.90',
        'public_network' => '192.168.126.90'
        } },
    'monasca' =>
      { 'ip' => {
        'normal_network' => '192.168.10.4',
        'admin_network' => '192.168.124.4',
        'public_network' => '192.168.126.4',
        'internal_network' => '192.168.127.4'
        },
        'fqdns' => ['monasca.monasca ', 'monasca'] },
    'openstack' =>
      { 'ip' => {
        'normal_network' => '192.168.10.5',
        'admin_network' => '192.168.124.5',
        'public_network' => '192.168.126.5',
        'internal_network' => '192.168.127.5'
        },
        'fqdns' => ['openstack.monasca', 'openstack'] },
    'ex_node_1' =>
      { 'ip' => {
        'normal_network' => '192.168.10.6',
        'admin_network' => '192.168.124.6',
        'public_network' => '192.168.126.6',
        'internal_network' => '192.168.127.6'
        },
        'fqdns' => ['exNode1.monasca', 'exNode1', 'ex_node_1'] },
    'ex_node_2' =>
      { 'ip' => {
        'normal_network' => '192.168.10.7',
        'admin_network' => '192.168.124.7',
        'public_network' => '192.168.126.7',
        'internal_network' => '192.168.127.7'
        },
        'fqdns' => ['exNode2.monasca', 'exNode2', 'ex_node_2'] },
    'ex_node_3' =>
      { 'ip' => {
        'normal_network' => '192.168.10.8',
        'admin_network' => '192.168.124.8',
        'public_network' => '192.168.126.8',
        'internal_network' => '192.168.127.8'
        },
        'fqdns' => ['exNode3.monasca', 'exNode3', 'ex_node_3'] },
      "admin_network" => {
        "ip" => "192.168.124.6",
        "fqdns" => ["admin.exNode1.monasca", "admin.exNode1", "admin.ex_node_1"],
      },
      "public_network" => {
        "ip" => "192.168.126.6",
        "fqdns" => ["public.exNode1.monasca", "public.exNode1", "public.ex_node_1"],
      },
      "internal_network" => {
        "ip" => "192.168.127.6",
        "fqdns" => ["internal.exNode1.monasca", "internal.exNode1", "internal.ex_node_1"],
      },
    },
    "ex_node_2" => {
      "normal_network" => {
        "ip" => "192.168.10.7",
        "fqdns" => ["exNode2.monasca", "exNode2", "ex_node_2"],
      },
      "admin_network" => {
        "ip" => "192.168.124.7",
        "fqdns" => ["admin.exNode2.monasca", "admin.exNode2", "admin.ex_node_2"],
      },
      "public_network" => {
        "ip" => "192.168.126.7",
        "fqdns" => ["public.exNode2.monasca", "public.exNode2", "public.ex_node_2"],
      },
      "internal_network" => {
        "ip" => "192.168.127.7",
        "fqdns" => ["internal.exNode2.monasca", "internal.exNode2", "internal.ex_node_2"],
      },
    },
    "ex_node_3" => {
      "normal_network" => {
        "ip" => "192.168.10.8",
        "fqdns" => ["exNode3.monasca", "exNode3", "ex_node_3"],
      },
      "admin_network" => {
        "ip" => "192.168.124.8",
        "fqdns" => ["admin.exNode3.monasca", "admin.exNode3", "admin.ex_node_3"],
      },
      "public_network" => {
        "ip" => "192.168.126.8",
        "fqdns" => ["public.exNode3.monasca", "public.exNode3", "public.ex_node_3"],
      },
      "internal_network" => {
        "ip" => "192.168.127.8",
        "fqdns" => ["internal.exNode3.monasca", "internal.exNode3", "internal.ex_node_3"],
      },
    },
  }

  virtual_ip = '192.168.126.69'

  ips_list = []
  for node in vms.keys
    for network in vms[node]['ip'].keys
      ips_list << vms[node]['ip'][network]
    end
  end
  ips_string = ips_list.join(",") + ",#{virtual_ip}"

  # Handle local proxy settings
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http = ENV["http_proxy"] if ENV["http_proxy"]
    config.proxy.https = ENV["https_proxy"] if ENV["https_proxy"]
    if ENV["no_proxy"]
      local_no_proxy = ",#{ips_string}"
      config.proxy.no_proxy = ENV["no_proxy"] + local_no_proxy
    end

    # config.proxy.http = "http://proxy.intern.est.fujitsu.com:8080"
    # config.proxy.https = "https://proxy.intern.est.fujitsu.com:8080"
    # config.proxy.no_proxy = "127.0.0.1,localhost,#{ips_string}"
  end

  config.timezone.value = :host if Vagrant.has_plugin?("vagrant-timezone")

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "clear-centos7"
    vms['master']['ip'].each do |key, value|
      master.vm.network :private_network, ip: value
    end
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible-master.yml"
    end
    master.vbguest.no_install = true if Vagrant.has_plugin?("vagrant-vbguest")
  end

  config.vm.define "openstack" do |openstack|
    openstack.vm.hostname = "openstack.monasca"
    openstack.vm.box = "devstack-centos7-liberty"
    openstack.vm.provision :hosts do |provision|
      provision.add_localhost_hostnames = false
      vms['monasca']['ip'].each do |key, value|
        provision.add_host value, vms['monasca']['fqdns']
      end
      #provision.add_host vms[:monasca][:ip], vms[:monasca][:fqdns]
        vms['ex_node_1']['ip'].each do |key, value|
          provision.add_host value, vms['ex_node_1']['fqdns']
        end
        vms['ex_node_2']['ip'].each do |key, value|
          provision.add_host value, vms['ex_node_2']['fqdns']
        end
        vms['ex_node_3']['ip'].each do |key, value|
          provision.add_host value, vms['ex_node_3']['fqdns']
        end
      end
    end
    vms['openstack']['ip'].each do |key, value|
      openstack.vm.network :private_network, ip: value
        end
          provision.add_host value["ip"], value["fqdns"]
        end
        vms["ex_node_3"].each do |key, value|
          provision.add_host value["ip"], value["fqdns"]
        end
      end
    end
    vms["openstack"].each do |key, value|
      openstack.vm.network :private_network, ip: value["ip"]
    end
    openstack.vm.provider "virtualbox" do |vb|
      vb.memory = 6192
      vb.cpus = 2
    end
    openstack.vbguest.no_install = true if Vagrant.has_plugin?("vagrant-vbguest")
  end

  config.vm.define "monasca" do |monasca|
    monasca.vm.hostname = "monasca.monasca"
    monasca.vm.box = "clear-centos7"
    monasca.vm.provision :hosts do |provision|
      provision.add_localhost_hostnames = false
      vms['monasca']['ip'].each do |key, value|
        provision.add_host value, vms['monasca']['fqdns']
      end
      vms['openstack']['ip'].each do |key, value|
        provision.add_host value, vms['openstack']['fqdns']
      end
        vms['ex_node_1']['ip'].each do |key, value|
          provision.add_host value, vms['ex_node_1']['fqdns']
        end
        vms['ex_node_2']['ip'].each do |key, value|
          provision.add_host value, vms['ex_node_2']['fqdns']
        end
        vms['ex_node_3']['ip'].each do |key, value|
          provision.add_host value, vms['ex_node_3']['fqdns']
        end
      end
    end
    vms['monasca']['ip'].each do |key, value|
      monasca.vm.network :private_network, ip: value
      end
        vms["ex_node_1"].each do |key, value|
          provision.add_host value["ip"], value["fqdns"]
        end
        vms["ex_node_2"].each do |key, value|
          provision.add_host value["ip"], value["fqdns"]
        end
        vms["ex_node_3"].each do |key, value|
          provision.add_host value["ip"], value["fqdns"]
        end
      end
    end
    vms["monasca"].each do |key, value|
      monasca.vm.network :private_network, ip: value["ip"]
    end
    monasca.vm.provider "virtualbox" do |vb|
      if enable_cluster == "1"
        vb.memory = 2048
        vb.cpus = 2
      else
        vb.memory = 6192
        vb.cpus = 2
      end
    end
    monasca.vbguest.no_install = true if Vagrant.has_plugin?("vagrant-vbguest")
  end

  if enable_cluster == "1"
    # extra nodes for cluster configuration
    config.vm.define "ex_node_1" do |ds|
      ds.vm.hostname = "exNode1.monasca"
      ds.vm.box = "clear-centos7"
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        vms.each do |key, value|
          if key != 'master'
            value['ip'].each do |key2, value2|
              provision.add_host value2, vms[key]['fqdns']
            end
          end
        end
      end
      vms['ex_node_1']['ip'].each do |key, value|
        ds.vm.network :private_network, ip: value
            end
        end
        vb.memory = 6096
      vms["ex_node_1"].each do |key, value|
        ds.vm.network :private_network, ip: value["ip"]
      end
      ds.vm.provider "virtualbox" do |vb|
        vb.memory = 6096
        vb.cpus = 2
      end
      ds.vbguest.no_install = true if Vagrant.has_plugin?("vagrant-vbguest")
    end

    config.vm.define "ex_node_2" do |ds|
      ds.vm.hostname = "exNode2.monasca"
      ds.vm.box = "clear-centos7"
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        vms.each do |key, value|
          if key != 'master'
            value['ip'].each do |key2, value2|
              provision.add_host value2, vms[key]['fqdns']
            end
          end
        end
      end
      vms['ex_node_2']['ip'].each do |key, value|
        ds.vm.network :private_network, ip: value
            end
        end
        vb.memory = 6096
      vms["ex_node_2"].each do |key, value|
        ds.vm.network :private_network, ip: value["ip"]
      end
      ds.vm.provider "virtualbox" do |vb|
        vb.memory = 6096
        vb.cpus = 2
      end
      ds.vbguest.no_install = true if Vagrant.has_plugin?("vagrant-vbguest")
    end

    config.vm.define "ex_node_3" do |ds|
      ds.vm.hostname = "exNode3.monasca"
      ds.vm.box = "clear-centos7"
      ds.vm.provision :hosts do |provision|
        provision.add_localhost_hostnames = false
        vms.each do |key, value|
          if key != 'master'
            value['ip'].each do |key2, value2|
              provision.add_host value2, vms[key]['fqdns']
            end
          end
        end
      end
      vms['ex_node_3']['ip'].each do |key, value|
        ds.vm.network :private_network, ip: value
            end
        end
        vb.memory = 6096
      vms["ex_node_3"].each do |key, value|
        ds.vm.network :private_network, ip: value["ip"]
      end
      ds.vm.provider "virtualbox" do |vb|
        vb.memory = 6096
        vb.cpus = 2
      end
      ds.vbguest.no_install = true if Vagrant.has_plugin?("vagrant-vbguest")
    end
  end
end
