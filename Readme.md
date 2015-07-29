# Monasca Installer

__Important:__ 
Code-changes may require the adaptation of User-Documentation at [CodeBeamer - Installation helper ansible](http://wwwi.est.fujitsu.com/cb/wiki/35690)

* [Introduction](#introduction)
* [Installation Guide for Developer](#installation-guide-for-developer)
  * [Requirements](#requirements)
  * [Clone](#clone)
  * [Proxy settings](#proxy-settings)
  * [Run monasca-installer against VMs](#run-monasca-installer-against-vms)
    * [Install CentOS7 and Openstack boxes](#install-centos7-and-openstack-boxes)
    * [Prepare hosts template file](#prepare-hosts-template-file)
    * [Start VMs](#start-vms)
    * [Prepare Ansible Master](#prepare-ansible-master)
    * [Prepare VMs](#prepare-vms)
    * [Install Monasca](#install-monasca)
  * [Test your installation](#test-your-installation)
  * [Work with vagrant-sandbox](#work-with-vagrant-sandbox)

## Introduction

This project contains installation scripts (written in Ansible) to install 
* Monasca
* Plugins, components and configuration on Openstack
* Monasca-Agent and Monasca-Log-Agent installation on Monasca and Openstack host

## Installation Guide for Developer

### Requirements
* Vagrant installed
* Virtualbox installed
* Git installed

#### Tested with:
* Vagrant 1.7.2
* Virtualbox 4.3.26
* Git 1.9.1

### Clone
```bash
git clone git@estscm1.intern.est.fujitsu.com:teammonitoring/monasca-installer.git
```

#### Init submodules
Run this command to install all submodules before:

```bash 
git submodule update --init
```

### Proxy settings
If you are behind a proxy, you will need to install the vagrant proxy plugin. Run this command:
```bash
vagrant plugin install vagrant-proxyconf
```

The proxy configuration is defined in Vagrantfile

```bash
vim Vagrantfile
```

```bash
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
  #config.proxy.http = "http://proxy.intern.est.fujitsu.com:8080"
  #config.proxy.https = "https://proxy.intern.est.fujitsu.com:8080"
  #config.proxy.no_proxy = "127.0.0.1,localhost,192.168.12.90,192.168.10.4,192.168.10.5"
end
```

If you are using the FTS Interceptor Gateway, and you don't have access to the internet, then change the content to:

* Remove conditions with content
* Remove # from the last three 'config' lines

```bash
# Handle local proxy settings
if Vagrant.has_plugin?("vagrant-proxyconf")
  config.proxy.http = "http://proxy.intern.est.fujitsu.com:8080"
  config.proxy.https = "https://proxy.intern.est.fujitsu.com:8080"
  config.proxy.no_proxy = "127.0.0.1,localhost,192.168.12.90,192.168.10.4,192.168.10.5"
end
```

### Run monasca-installer against VMs

#### Install CentOS7 and Openstack boxes

##### Copy boxes
Copy vagrant boxes from smb://estfile5/projects/CloudWatchManager/vagrant-boxes
* clear_centos7.box
* devstack_centos_7.box

##### Install boxes
Add box to your local vagrant environment
```bash
vagrant box add monasca-devstack-centos /path/to/the/devstack_centos_7.box
vagrant box add clear-centos7 /path/to/the/clear_centos7.box
```

#### Prepare hosts template file
__Important:__ 
The vagrant box 'monasca-devstack-centos' works only with ip 192.168.10.5. Otherwise the installation may fail

If you are using different IPs, then you have to change the ips in ansible-master.yml

```bash
vim ansible-master.yml
```

```bash
vars:
    monasca-host: 192.168.10.4
    openstack-host: 192.168.10.5
```

and in group_vars/all_group

```bash
vim group_vars/all_group
```

```bash
# hosts
offline_host: 192.168.10.4
monasca_host: 192.168.10.4
keystone_host: 192.168.10.5
monasca_log_api_host: 192.168.10.4
openstack_host: 192.168.10.5
```

#### Start VMs

```bash
cd monasca-installer
```

```bash
vagrant up
```

__Important:__ If password is prompted, type 'vagrant'

#### Prepare Ansible Master

Most of the ansible master prepare installation is already done automatically by running 'vagrant up'.

If you want to trigger the automated installation again, run this command:

```bash
vagrant provision master
```

#### Prepare VMs

We need to make sure, that all hosts can be reached via ssh from ansible-master host.

```bash
vagrant ssh master
```

##### Copy ssh key to monasca VM
```bash
ssh-copy-id vagrant@192.168.10.4
```
Response:
```bash
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@192.168.12.102's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'vagrant@192.168.10.4'"
and check to make sure that only the key(s) you wanted were added.
```

##### Copy ssh key to openstack VM
```bash
ssh-copy-id vagrant@192.168.10.5
```

```bash
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@192.168.10.5's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'vagrant@192.168.10.5'"
and check to make sure that only the key(s) you wanted were added.
```

#### Install Monasca

Connect to the ansible-master VM

```bash
vagrant ssh master
```

Goto vagrant folder

```bash
cd /vagrant
```

and run main.yml

```bash
ansible-playbook main.yml
```

### Test your installation
Open http://192.168.10.5 in your browser.
Login credentials are:

| user | password |
| -------- | -------- |
| admin | admin |
| csi-operator | password |

### Work with vagrant-sandbox
Sahara allows vagrant to operate in sandbox mode

#### Install
```bash
vagrant plugin install sahara
```

#### Usage

Enter sandbox mode:
```bash
vagrant sandbox on
```

Do some stuff:
```bash
vagrant ssh 
```

If satisfied, apply the changes permanently:
```bash
vagrant sandbox commit
```

If not satisfied, rollback to the previous commit:
```bash
vagrant sandbox rollback
```

Exit sandbox mode:
```bash
vagrant sandbox off
```

Check sandbox status:
```bash
vagrant sandbox status
```