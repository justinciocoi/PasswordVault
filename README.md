# Password Vault Tool

## Introduction and Details

This tool uses AES encryption and SSH connection to encrypt and remotely backup your passwords to a self-hosted remote server. This tool is very barebones and is intended to be used as a backup to a traditional password manager in case of third-party data loss. This tool was developed with macOS and Linux in mind, and tested on macOS Sonoma 14.12.1 and Debian 12.5.

## Prerequisites for Use

We will assume you have an existing SSH connection to a remote machine which will be used as the password server. For more info on setting up an SSH connection, click [here](https://www.strongdm.com/blog/ssh-passwordless-login)

It is also advisable to add a host entry for your remote machine in your `/etc/ssh/ssh_config` in the following form

```bash
Host [HostName] #your HostName can be used in the future to access SSH
    HostName [IP Address]
    User [Username]
    Port [Port No.]
    IdentityFile [/path/to/identity/file]
# IdentityFile only relevant if passwordless SSH is set up
```

## Encryption Set-Up

The passwordBackup.sh script will backup a password to your remote server. This script will run on your client machine and transfer encrypted password information to the password server. First, clone the repository:

```
git clone https://github.com/justinciocoi/passwordVault
```

In order to make the script executable, use the following commands in your client terminal to navigate into the cloned repository and make the script executable:

```
cd passwordVault
chmod +x passwordBackup.sh
```

which can then be executed using `./passwordBackup.sh` 

## Decryption Set-Up

To maintain confidentiality, the AES encryption key should be stored only on the client machine such that the server machine alone does not contain the means to reproduce stored credentials. 

## Client Usage

## Decryption Usage
