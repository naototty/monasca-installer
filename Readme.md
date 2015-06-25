# Introduction

Detailed Ansible installation/configuration information on
* [CodeBeamer - Installation helper ansible](http://wwwi.est.fujitsu.com/cb/wiki/35690)
* [Ansible Official documentation](http://docs.ansible.com/intro.html)

# Content
├── .git
├── .gitignore
├── .gitmodules
├── main.yml
├── monasca-agent.yml
├── monasca.yml
├── offline.yml
├── openstack.yml
├── Readme.md
├── requirements.yml
├── roles
├── tests
└── Vagrantfile

# Requirements
* Vagrant installed
* Virtualbox installed
* Git installed

## Tested with:
* Vagrant 1.7.2
* Virtualbox 4.3.26
* Git 1.9.1

# Clone
```bash
git clone git@estscm1.intern.est.fujitsu.com:teammonitoring/monasca-installer.git
```

# Init submodules
```bash
git submodule init
git submodule update
```

# Do you use a Proxy?
If you are behind a proxy, you will need to install the vagrant proxy plugin. Run this command:
```bash
vagrant plugin install vagrant-proxyconf
```

Proxy configuration is defined in Vagrantfile

```bash
cd monasca-installer
```

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

# Run monasca-installer against VM's

## Install CentOS7 and Openstack boxes

### Copy boxes
Copy vagrant boxes from smb://estfile5/projects/CloudWatchManager/vagrant-boxes
* clear_centos7.box
* devstack_centos_7.box

### Install boxes
Add box to your local vagrant environment
```bash
vagrant box add monasca-devstack-centos /path/to/the/devstack_centos_7.box
vagrant box add clear-centos7 /path/to/the/clear_centos7.box
```

## Start VM's

```bash
cd monasca-installer
```

```bash
vagrant up
```

__Important:__ If password is prompted, type 'vagrant'

## Install Ansible Master
How-To: [Install Ansible](http://wwwi.est.fujitsu.com/cb/wiki/35690#section-Installation)

### Configure Ansible Master

```bash
cd monasca-installer
```

```bash
vagrant ssh master
```

### Generate ssh key

```bash
ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vagrant/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/vagrant/.ssh/id_rsa.
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub.
The key fingerprint is:
```

### Configure /etc/ansible/hosts
```bash
sudo vim /etc/ansible/hosts
```

Add this content:
```bash
[offline]
192.168.10.4

[openstack]
192.168.10.5

[monasca]
192.168.10.4
```

## Prepare VM's

First we need to make sure, that all hosts can be reached via ssh from ansible-master host.

### Copy ssh key to monasca VM
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

### Copy ssh key to openstack VM
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

## Install PostgreSQL Dependency
Ansible installer assumes that all necessary yum packages are available in the yum repository. Because of, we need to copy the PostgreSQL package information into the yum repository.

Make postgresql 9.4 available for your Operating System

```bash
cd monasca-installer
```

Connect to monasca VM
```bash
vagrant ssh monasca
```

Download Rpm Package
```bash
wget http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm
```

Response: 
```bash
--2015-06-23 06:36:23--  http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm
Resolving proxy.intern.est.fujitsu.com (proxy.intern.est.fujitsu.com)... 192.168.210.81
Connecting to proxy.intern.est.fujitsu.com (proxy.intern.est.fujitsu.com)|192.168.210.81|:8080... connected.
Proxy request sent, awaiting response... 200 OK
Length: 5328 (5,2K) [application/x-redhat-package-manager]
Saving to: ‘pgdg-centos94-9.4-1.noarch.rpm’

100%[============================================================================>] 5.328       --.-K/s   in 0s

2015-06-23 06:36:28 (418 MB/s) - ‘pgdg-centos94-9.4-1.noarch.rpm’ saved [5328/5328]
```

Install Rpm Package
```bash
sudo yum install pgdg-centos94-9.4-1.noarch.rpm
```

## Install Monasca

Connect to the ansible-master VM

```bash
cd monasca-installer
```

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

# Install Agents

## Install Monasca Metric Agent

## Install Monasca Log Agent

# TODO
* Split Elkstack
* minify variables
* remove monasca-agent dependency in openstack part