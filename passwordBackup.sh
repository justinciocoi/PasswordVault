##Justin Ciocoi 3/20/24
#Tool to backup encrypted passwords to a remote machine

# Check for a saved configuration file
CONFIG_FILE="$HOME/.password_tool_config"

# Check for the hidden .key folder and aes_key.txt file
KEY_FOLDER="$HOME/.key"
AES_KEY_FILE="aes_key.txt"

if [ -d "$KEY_FOLDER" ] && [ -f "$KEY_FOLDER/$AES_KEY_FILE" ]; then
    echo "AES key file found."
    read -p "Use this AES key? (y/n): " USE_KEY
    if [[ $USE_KEY =~ ^[Yy]$ ]]; then
        AES_KEY_PATH="$KEY_FOLDER/$AES_KEY_FILE"
    else
        read -p "Use your own key? (no will generate a default key in the default directory) (y/n): " OWN_KEY
        if [[ $OWN_KEY =~ ^[Yy]$ ]]; then
            read -p "Enter path to your AES key: " AES_KEY_PATH
        else
            openssl rand -base64 32 > "$KEY_FOLDER/$AES_KEY_FILE"
            echo "New AES key generated and saved to $KEY_FOLDER/$AES_KEY_FILE"
            AES_KEY_PATH="$KEY_FOLDER/$AES_KEY_FILE"
        fi
    fi
else
    echo "AES key file not found in the .key folder."
    read -p "Would you like to create a new AES key and directory? (y/n): " CREATE_KEY_DIR

    if [[ $CREATE_KEY_DIR =~ ^[Yy]$ ]]; then
        mkdir -p "$KEY_FOLDER"
        # Generate a new AES key and save it to aes_key.txt
        openssl rand -base64 32 > "$KEY_FOLDER/$AES_KEY_FILE"
        echo "New AES key generated and saved to $KEY_FOLDER/$AES_KEY_FILE"
        AES_KEY_PATH="$KEY_FOLDER/$AES_KEY_FILE"
    else
        read -p "Enter the full path to your AES key: " AES_KEY_PATH
    fi
fi




if [ -f "$CONFIG_FILE" ]; then
    read -p "Found a saved configuration. Would you like to use it? (y/n): " USE_SAVED
    if [[ $USE_SAVED =~ ^[Yy]$ ]]; then
        echo "Loading saved configuration..."
        source "$CONFIG_FILE"
    else
        # Prompt the user for remote host details and AES key details
        read -p "Enter the username for the remote host: " USER
        read -p "Enter the host address: " HOST 
        read -p "Enter the full path to the remote directory: " REMOTE_DIR

        # Ask if the user wants to save these details for future use
        read -p "Would you like to save these details for future use? (y/n): " SAVE_CHOICE
        if [[ $SAVE_CHOICE =~ ^[Yy]$ ]]; then
            echo "Saving configuration..."
            echo "USER='$USER'" > "$CONFIG_FILE"
            echo "HOST='$HOST'" >> "$CONFIG_FILE"
            echo "REMOTE_DIR='$REMOTE_DIR'" >> "$CONFIG_FILE"
            echo "AES_KEY_PATH='$AES_KEY_PATH'" >> "$CONFIG_FILE"
        fi
    fi
    else
         # Prompt the user for remote host details and AES key details
        read -p "Enter the username for the remote host: " USER
        read -p "Enter the host address: " HOST 
        read -p "Enter the full path to the remote directory: " REMOTE_DIR

        # Ask if the user wants to save these details for future use
        read -p "Would you like to save these details for future use? (y/n): " SAVE_CHOICE
        if [[ $SAVE_CHOICE =~ ^[Yy]$ ]]; then
            echo "Saving configuration..."
            echo "USER='$USER'" > "$CONFIG_FILE"
            echo "HOST='$HOST'" >> "$CONFIG_FILE"
            echo "REMOTE_DIR='$REMOTE_DIR'" >> "$CONFIG_FILE"
            echo "AES_KEY_PATH='$AES_KEY_PATH'" >> "$CONFIG_FILE"
        fi
fi



# Prompt the user to enter their own password
read -p "Enter the password you wish to encrypt: " PASSWORD
echo # move to a new line

# Prompt for the output filename without the .txt extension
read -p "Enter the desired output filename (without extension): " FILENAME

# Encrypt the password
echo "$PASSWORD" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -iter 10000 -pass file:$AES_KEY_PATH -out "${FILENAME}.txt"

# Securely transfer the encrypted password file to the remote machine
scp "${FILENAME}.txt" $USER@$HOST:$REMOTE_DIR

if [ $? -eq 0 ]; then
    echo "Password encrypted and transferred successfully."
else
    echo "An error occurred during the transfer."
fi

# Optional: Remove the local temporary encrypted password file for security
rm -f "${FILENAME}.txt"
