# Password Vault Tool

This tool uses AES encryption and SSH connection to encrypt and remotely backup your passwords to a self-hosted remote server. This tool is very barebones and is intended to be used as a backup to a traditional password manager in case of third-party data loss.

We will assume you have an existing SSH connection to a remote machine which will be used as the password server. For more info on setting up an SSH connection, click [here](https://chat.openai.com/share/5256298b-88ce-4887-b0b0-150f0134f576)

It is also advisable to add a host entry for your remote machine in your `/etc/ssh/sssh_config` in the following form

```bash
Host [HostName]
    HostName [IP Address]
    User [Username]
    Port [Port No.]
    IdentityFile [/path/to/identity/file]
# IdentityFile only relevant if passwordless SSH is set up
```
