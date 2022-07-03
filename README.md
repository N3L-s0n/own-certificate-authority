# Own Certificate Authority (CA)

## Requirements

To build this Certificate Authority you need some basic requirements.
- A linux machine where this repo is cloned (control node).
- A CentOS 7 machine where the CA is going to be build (managed node or host).
- SSH access to the remote host.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on your local host or remote host.

> Note: The control node and host could be both the same. In this case everything is run locally.

There are many ways to run the build, we're going to describe two examples.
- [Running Ansible in host](#running-ansible-in-remote-host).
- [Control node and managed node](#control-node-and-managed-node).

To create a request that can be signed by this CA go to [this section](#creating-a-certificate-signing-request-(csr)-for-a-web-server)

## Running Ansible in remote host

In this case Ansible is installed in the remote host.

### Install Ansible in remote host & clone repository

If Ansible is not installed in the remote host you can run the script in `scripts/ansible-install.sh`. To do this log into your remote machine using `ssh` then download the script with `wget` and make it executable to finally run it as root (sudo is needed since we're going to use yum to install ansible).

```sh
wget https://raw.githubusercontent.com/N3L-s0n/own-certificate-authority/master/scripts/ansible-install.sh && chmod +x ansible-install.sh && sudo ./ansible-install.sh
```

This script is going to update the yum repositories and install an older version of Ansible which is fine for now, it will also install git to clone this repository.

```sh
git clone https://github.com/N3L-s0n/own-certificate-authority.git && cd own-certificate-authority
```

### Install OpenSSL and Python3.10

Now that we have where to run our playbooks we can execute the `playbooks/setup.yml` playbook. It needs no variables but you can choose different OpenSSL and Python3.10 versions. This was tested using [openssl-1.1.1p](https://www.openssl.org/source/) and [Python-3.10.5](https://www.python.org/downloads/release/python-3105/)

```sh
# playbooks/setup.yml
---
- hosts: all

# This playbook runs all setup needed to use community.crypto 2.3.2 if using default variables
  roles:
    - role: openssl-install
    - role: python3-install
    - role: ansible-install
      tags: [ local ]
    - role: cryptography-install

```

To run the playbook you have to set the host machine and connection, since we're running ansible locally we have to use the command shown below. You can add the tags argument to only run certain parts of the roles, e.g `--tags openssl-dependencies` will only install packages needed for openssl using yum. You also can set the openssl and python version, e.g `--extra-vars "openssl_version=3.0.4`. 

<br>

Change **&lt;user&gt;** with the username you used with ssh.

```sh
ansible-playbook -i localhost, --connection local playbooks/setup.yml -u <user>
```

Run `hash -r` to forget about ansible previous location

```sh
hash -r
```

<br>

Now if you run `ansible --version` you should get at least `ansible [core 2.13.1]`. We'll use [Community.Crypto](https://docs.ansible.com/ansible/latest/collections/community/crypto/index.html) which should be already installed, you can check it by running `ansible-galaxy collection list` and searching for community.crypto.
After this we should have OpenSSL, Python3.10, [Cryptography](https://pypi.org/project/cryptography/) and Ansible > core 2.13.0. 

### Selfsigned CA certificate

Now to get a certificate for our CA, we need to create a private key with a passphrase, a certificate signing request (CSR) and then create the certificate from this CSR using the generated key. This is all done by the playbook `playbooks/ownca-certificate.yml` you just need to set the variable for the passphrase, e.g `--extra-vars "secret_ca_passphrase=test_password"`. The private key uses the **RSA** cryptosystem with a **2048** size. Certificate basic data like country name and state can also be set using variables. The defaults one are:

```sh
# playbooks/roles/ownca-certificate/defaults/main.yml
# You must change these according to your needs
---
country_name:             "CR"
state_or_province_name:   "San Jose"
locality_name:            "San Pedro"
organization_name:        "CI-0143 I-2022 Ltd"
organizational_unit_name: "Grupo 1"
common_name:              "Seguridad grupo 1 CA"

```

To run the playbook execute the command below.

<br>

Change **&lt;user&gt;** with the username you used with ssh and **&lt;password&gt;** with your passphrase for the key.

```sh
ansible-playbook -i localhost, --connection local playbooks/ownca.yml -u <user> --extra-vars "secret_ca_passphrase=<password>"
```

The private key and certificate are created in **/etc/pki/CA/private/** and **/etc/pki/CA/certs/** respectively.

### Signing certificate signing requests (CSR)

We also included a playbook to sign request, first you need the request file stored in the CA machine, `scp` can be use to upload the file to the *Request/* directory which was created in the previous playbook. Run the following command if the CSR file is not in the remote machine yet.

<br>

Change **&lt;user&gt;** with the username you used with ssh, **&lt;ip&gt;** with your remote machine IP address and **&lt;path/to/csr&gt;** with the path to the CSR file, e.g `/tmp/www.test.com.csr`.

```sh
scp <path/to/csr> <user>@<ip>:~/Requests/.
```

To sign this request use `playbooks/sign.yml`. Change **&lt;user&gt;** with the username you used with ssh, **&lt;password&gt;** with your passphrase for the key and **&lt;*csr&gt;** with the name of the CSR file, e.g `www.test.com.csr`.

```sh
ansible-playbook -i localhost, --connection local playbooks/sign.yml -u <user> --extra-vars "csr_file=<*.csr> secret_ca_passphrase=<password>"
```

The signed certificate should now exists in the *Request/* directory with the same name but .crt extension. Send this file to the server which requested it.

## Control node and managed node

In this case Ansible is installed in a control node.


## Creating a certificate signing request (CSR) for a web server

To create a CSR for our web server you should have Ansible installed in the web server or a control node.

### Ansible installed in web server

In this case you should clone the repository and run the setup playbook to install dependencies like OpenSSL 1.1.x and Cryptography. This will also install Ansible using pip3.10.

```sh
ansible-playbook -i localhost, --connection local playbooks/setup.yml -u <user> && hash -r
```

Now run the playbook to create the CSR file. Default values are:
```sh
# playbooks/roles/server-request/defaults/main.yml
---
country_name:             "CR"
state_or_province_name:   "San Jose"
locality_name:            "San Pedro"
organization_name:        "CI-0143 I-2022 Ltd"
organizational_unit_name: "Grupo 1"
common_name:              "www.test.com"

dir_key: "/etc/pki/tls/private"
dir_csr: "/etc/pki/tls/certs"
```

Change **&lt;user&gt;** with your machine username, **&lt;password&gt;** with a new passphrase for the key and **&lt;common_name&gt;** with the **hostname**
> Note: the hostname is going to be added to the Subject Alternative Names (SAN) list of the request with the domain too.

```sh
ansible-playbook -i localhost, --connection local playbooks/server.yml -u <user> --extra-vars "secret_passphrase=<password> common_name=<common_name>"
```

Now you should have the request file in the `/etc/pki/tls/certs/` directory if you didn't change the variable `dir_csr`
