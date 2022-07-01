# Own Certificate Authority (CA)


## Requirements
To build this Certificate Authority you need some basic requirements.
- A linux machine where this repo is cloned (local host).
- A CentOS 7 machine where the CA is going to be build (remote host).
- SSH access to the remote host.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on your local host or remote host.

Note: The local and remote machine could be both the same. In this case everything is run locally.

## Prepare the enviroment (Using two machines & running Ansible in remote host)
If Ansible is not installed in the remote host you can run the script in `scripts/ansible-install.sh`. To do this you can use the following comand from the repository main directory where &lt;user&gt; is the username of the remote machine and &lt;host&gt; the IP address or hostname of the remote machine.
```
ssh <user>@<host> 'bash -s' < scripts/ansible-install.sh
```
