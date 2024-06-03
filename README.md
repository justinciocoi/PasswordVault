# Password Vault Tool

## Introduction and Details

This tool uses AES encryption and SSH connection to encrypt and remotely backup your passwords to a self-hosted remote server. This tool is very barebones and is intended to be used as a backup to a traditional password manager in case of third-party data loss or loss of a portable personal computer. This tool was developed with macOS and Linux in mind, and tested on macOS Sonoma 14.12.1 and Debian 12.5.

## Prerequisites for Use

We will assume you have an existing SSH connection to a remote machine which will be used as the password server. For more info on setting up an SSH connection, click [here](https://www.strongdm.com/blog/ssh-passwordless-login)

It is also advisable to set up passwordless SSH and add a host entry for your remote machine in your `/etc/ssh/ssh_config` in the following form

```bash
Host [HostName] #your HostName can be used in the future to access SSH
    HostName [IP Address]
    User [Username]
    Port [Port No.]
    IdentityFile [/path/to/identity/file]
# IdentityFile only relevant if passwordless SSH is set up
```

## Encryption Set-Up

The `passwordBackup.sh` script will backup a password to your remote server. This script will run on your client machine and transfer encrypted password information to the password server. First, clone the repository:

```bash
git clone https://github.com/justinciocoi/passwordVault
```

In order to make the script executable, use the following commands in your client terminal to navigate into the cloned repository and make the script executable:

```bash
cd passwordVault
chmod +x passwordBackup.sh
```

which can then be executed using: `./passwordBackup.sh`

In order to make this script executable from any directory in your terminal, use the following command to add the project directory to your system's PATH:

```bash
sudo echo "export PATH=/path/to/scrpts:$PATH" >> ~/.zshrc
#change to bashrc if necessary
```

Now, the script should be usable from anywhere in your terminal as follows:

```bash
passwordBackup.sh
```

## Decryption Set-Up

To maintain confidentiality, the AES encryption key should be stored only on the client machine such that the server machine alone does not contain the means to reproduce stored credentials. 

The `decryptVault.sh` script is used to fetch encryted content from the vault over ssh, decrypt the content, and display it to the user. Once again, we must first make the script executable.

```bash
cd passwordVault
chmod +x decryptVault.sh
```

If the directory was added to your system's PATH in the previous step, there is no need to do this again. The decryption script should now be usable on your machine from any directory with the following command:

```bash
decryptVault.sh
```

## Encryption Usage

The `passwordBackup.sh` script will begin by checking to see if an AES key exists in the script's default `$HOME/.key/` directory. If it does not, you will be prompted to generate a new key in the default location or enter the full path to a different AES key. 

After the AES key is located, the script will prompt you for details on the SSH connection which will be used. You must enter the username on the remote host, the remote host's name (IP Address), and the full path to your vault directory on the remote machine. 

Once these details are retrieved by the program, it will ask if you would like to save this configuration for future use. 

Once configurations are fully loaded, the script will ask you for the password to be encrypted, as well as the filename which will be used to store the password in your remote vault. 

## Decryption Usage

The `decryptVault.sh` script will similarly begin by checking for an AES key in the default location. If not found, you must enter the full path to the AES key which was used for encryption as this is necessary to decrypt the files.

It will follow the same processes of gathering configurations from the user and prompting the user to save configurations.

Finally, it will prompt the user for the name of the file to be decrypted, and display the decrypted credentials to the console.

## Example

```bash
justinciocoi@Justins-MBP ~ % encrypt
AES key file found.
Use this AES key? (y/n): y
Found a saved configuration. Would you like to use it? (y/n): y
Loading saved configuration...
Enter the password you wish to encrypt: password

Enter the desired output filename (without extension): password
password.txt                                  100%   45     1.2KB/s   00:00
Password encrypted and transferred successfully.
justinciocoi@Justins-MBP ~ % decrypt
AES Key file found in default directory
Use this AES key? (y/n): y
Found a saved configuration. Would you like to use it? (y/n): y
Loading saved configuration...
Enter the filename whose contents will be decrypted (without the .txt extension): password
password.txt                                  100%   45     0.6KB/s   00:00
Decrypted content is:
password
justinciocoi@Justins-MBP ~ %
```

In this example, alias were created in the shell configuration file in order to use the commands `encrypt` and `decrypt` respectively. You can create these same aliases using the following command

```bash
echo "alias encrypt="passwordBackup.sh"" >> ~/.zshrc
echo "alias decypt="decryptVault.sh""  >> ~/.zshrc
source ~/.zshrc
#change to ~/.bashrc if you are using bash
```