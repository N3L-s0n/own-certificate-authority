# Own Certificate Authority (CA)

## Requirements

To build this Certificate Authority you need some basic requirements.
- A linux machine where this repo is cloned (local host).
- A CentOS 7 machine where the CA is going to be build (remote host).
- SSH access to the remote host.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on your local host or remote host.

Note: The local and remote machine could be both the same. In this case everything is run locally.

There are many ways to run the build, we're going to describe two examples.
- [Running Ansible in remote host](#running-ansible-in-remote-host).
- [Running Ansible in local host](#running-ansible-in-local-host).

To run the examples go ahead a clone the repository on your local machine in the folder you want.

## Running Ansible in remote host

In this case Ansible is installed in the remote host.

### Install Ansible in remote host & clone repository

If Ansible is not installed in the remote host you can run the script in `scripts/ansible-install.sh`. To do this you can use the following comand from the repository main directory where &lt;user&gt; is the username of the remote machine and &lt;host&gt; the IP address or hostname of the remote machine. This script is going to update the yum repositories and install an older version of Ansible which is fine for now, it will install git too.

```sh
$ ssh <user>@<host> 'bash -s' < scripts/ansible-install.sh
```
After this we have to get an ssh console in the machine and clone the repository here too. Run this command in your user's home directory
```sh
$ git clone https://github.com/N3L-s0n/own-certificate-authority.git
```

### Install OpenSSL and Python3.10

Now that we have where to run our playbooks we can execute the `playbooks/ownca-setup.yml` playbook. It needs no variables but you can choose different OpenSSL and Python3.10 versions. This was tested using [openssl-1.1.1p](https://www.openssl.org/source/) and [Python-3.10.5](https://www.python.org/downloads/release/python-3105/)

```sh
---
- hosts: all

# This playbook runs all setup needed to use community.crypto 2.3.2 if using default variables
  roles:
    - openssl-install
    - python3-install
    - ansible-install
    - cryptography-install

```

To run the playbook you have to set the host machine and connection, since we're running ansible locally we have to use the command shown below. You can add the tags argument to only run certain parts of the roles, e.g `--tags openssl-dependencies` will only install packages needed for openssl using yum. You also can set the openssl and python version, e.g `--extra-vars "openssl_version=3.0.4`. 

<br>

Change **&lt;user&gt;** with the username you used with ssh.

```sh
$ ansible-playbook -i localhost, --connection local playbooks/ownca-setup.yml -u <username>
$ export PATH="~/.local/bin:$PATH"
```



<br>

After this we should have OpenSSL, Python3.10, [Cryptography](https://pypi.org/project/cryptography/) and Ansible > core 2.13.0. 

## Running Ansible in local host

In this case Ansible is installed in our local host.
