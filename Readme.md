# Introduction

Detailed Ansible installation/configuration information on
* [CodeBeamer - Installation helper ansible](http://wwwi.est.fujitsu.com/cb/wiki/35690)
* [Ansible Official documentation](http://docs.ansible.com/intro.html)

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

# Start VM's

```bash
vagrant up
```

__Important:__ If password is prompted, type 'vagrant'

## Install Ansible Master
How-To: [Install Ansible](http://wwwi.est.fujitsu.com/cb/wiki/35690#section-Installation)

## Configure Ansible Master

```bash
vagrant ssh master
```

## Generate ssh key

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

# Install Offline part

## Copy ssh key to monasca VM
```bash
[vagrant@master ~]$ ssh-copy-id vagrant@192.168.12.102
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@192.168.12.102's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'vagrant@192.168.12.102'"
and check to make sure that only the key(s) you wanted were added.
```

## Run offline.yml

```bash
vagrant ssh master
[vagrant@master ~]$ cd /vagrant
[vagrant@master vagrant]$ ansible-playbook offline.yml
```

If succesful, you should see something like this:

```bash
PLAY RECAP ******************************************************************** 
192.168.12.102             : ok=18   changed=8    unreachable=0    failed=0
```

# Install Openstack part

## Copy ssh key to openstack VM
```bash
[vagrant@master ~]$ ssh-copy-id vagrant@192.168.10.5
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
vagrant@192.168.10.5's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'vagrant@192.168.10.5'"
and check to make sure that only the key(s) you wanted were added.
```

## Run openstack.yml

```bash
vagrant ssh master
[vagrant@master ~]$ cd /vagrant
[vagrant@master vagrant]$ ansible-playbook openstack.yml
```

If succesful, you should see something like this:

```bash
PLAY RECAP ******************************************************************** 
192.168.10.5               : ok=31   changed=5    unreachable=0    failed=0
```

# Install Monasca part

## Prepare

Make postgresql 9.4 available for your Operating System

```bash
vagrant ssh monasca
[vagrant@monasca ~]$ wget http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm
--2015-06-23 06:36:23--  http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm
Resolving proxy.intern.est.fujitsu.com (proxy.intern.est.fujitsu.com)... 192.168.210.81
Connecting to proxy.intern.est.fujitsu.com (proxy.intern.est.fujitsu.com)|192.168.210.81|:8080... connected.
Proxy request sent, awaiting response... 200 OK
Length: 5328 (5,2K) [application/x-redhat-package-manager]
Saving to: ‘pgdg-centos94-9.4-1.noarch.rpm’

100%[============================================================================>] 5.328       --.-K/s   in 0s      

2015-06-23 06:36:28 (418 MB/s) - ‘pgdg-centos94-9.4-1.noarch.rpm’ saved [5328/5328]

[vagrant@monasca ~]$ sudo yum install pgdg-centos94-9.4-1.noarch.rpm
```

## Run monasca.yml

```bash
vagrant ssh master
[vagrant@master ~]$ cd /vagrant
[vagrant@master vagrant]$ ansible-playbook monasca.yml
```

If succesful, you should see something like this:

```bash
PLAY RECAP ******************************************************************** 
192.168.10.5               : ok=31   changed=5    unreachable=0    failed=0
```

# Install Agents

## Install Monasca Metric Agent

## Install Monasca Log Agent

# TODO
* Split Elkstack
* minify variables
* remove monasca-agent dependency in openstack part