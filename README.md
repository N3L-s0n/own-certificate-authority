# Own Certificate Authority (CA)

## Requirements

To build this Certificate Authority you need some basic requirements.
- A linux machine where this repo is cloned (local host).
- A CentOS 7 machine where the CA is going to be build (remote host).
- SSH access to the remote host.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on your local host or remote host.

Note: The local and remote machine could be both the same. In this case everything is run locally.

There are many ways to run the build, we're going to describe two examples, both of them uses two machines and we're going to run all the commands listed here in our local machine. **We don't need a console in the remote host**.
- [Running Ansible in remote host](#running-ansible-in-remote-host).
- [Running Ansible in local host](#running-ansible-in-local-host).

To run the examples go ahead a clone the repository on your local machine in the folder you want.

## Running Ansible in remote host

In this case Ansible is installed in the remote host.

### Install Ansible in remote host

If Ansible is not installed in the remote host you can run the script in `scripts/ansible-install.sh`. To do this you can use the following comand from the repository main directory where &lt;user&gt; is the username of the remote machine and &lt;host&gt; the IP address or hostname of the remote machine.

```
ssh <user>@<host> 'bash -s' < scripts/ansible-install.sh
```

## Running Ansible in local host

In this case Ansible is installed in our local host.
