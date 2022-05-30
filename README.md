# Ansible Playbook Skeleton 🚀

An Ansible Playbook Skeleton with some scripts to pull the config and the roles from other repos plus to connect everything.

## How To 🎓

To get started you will use the `init.sh` file from this repository.
It will help you create the neccessary folders and to automatically connect everything.
The **basic setup** includes at least two additional git repositories:

1. A Config Repository
   This will hold your playbook, the inventory file, variables and your vault.
   For a quickstart you can use the example config repository [here](https://github.com/BennyLi/ansible-config-example).
2. A Roles Repository
   This will include all the Ansible roles you use in your playbook.
   You can find my public roles repository [here](https://github.com/BennyLi/ansible-roles).

You can add even more repositories to the **extended setup**:

3. A Public Dotfiles Repository
   If you like to seperate things and be more independet from Ansible, you can add a public repository.
   You can find my public dotfiles repository [here](https://github.com/BennyLi/dotfiles).
   But what about my sensitive data?
   I don't like to add my private, sensible data (like credentials) to a public Git repository, even when this data is encrypted, too.
   So I seperate these informations and you may too.
   The above mentioned config repository holds the Ansible variables and your vault.
   Store your sensitive data there and put variables into the Dotfiles, that will be replaced by Ansible on playbook execution.
4. A Dockerfiles Repository
   Some applications of mine are running inside Docker containers.
   The setup is maintained seperatly in a dedicated Git repository (which you can find [here](https://github.com/BennyLi/dockerfiles)).

After you have created all your Git repositories, you should **configure** them in the `init.sh` file.
Therefor some variables are available at the beginning of the file, which are self-explanatory and documented there.

Finally **run** the `init.sh` file in your shell.
