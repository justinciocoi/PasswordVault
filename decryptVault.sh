#!/bin/bash

#Check for AES Key in default location
#AES Key used for encryption is needed to decrypt content

KEY_FOLDER="$HOME/.key"
AES_KEY_FILE="aes_key.txt"

CONFIG_FILE="$HOME/.decryption_tool_config"

#Hey chatGPT, the decrypted content of the second script is not working properly, any reason why?
if [ -d "$KEY_FOLDER" ] && [ -f "$KEY_FOLDER/$AES_KEY_FILE" ]; then
    echo "AES Key file found in default directory"
    read -p "Use this AES key? (y/n): " USE_KEY
    if [[ $USE_KEY =~ ^[Yy]$ ]]; then
        AES_KEY_PATH="$KEY_FOLDER/$AES_KEY_FILE"
    else
        read -p "Enter path to your AES key used for encryption: " AES_KEY_PATH
    fi
else
    read -p "Enter path to your AES key used for encryption: " AES_KEY_PATH
    if [ -f "$AES_KEY_PATH" ]; then
        echo "AES key file found."
    else
        echo "You must have an AES key file which was used in encryption. Script Exiting."
        exit 1
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

#prompt the user for file name
read -p "Enter the filename whose contents will be decrypted (without the .txt extension): " FILENAME

#fetch the password using ssh configuration
scp $USER@$HOST:$REMOTE_DIR/"${FILENAME}.txt" .

# Decrypt the file
openssl enc -aes-256-cbc -d -a -pbkdf2 -iter 10000 -pass file:$AES_KEY_PATH -in "${FILENAME}.txt" -out "${FILENAME}_decrypted.txt"

# Display the decrypted contents
if [ -f "${FILENAME}_decrypted.txt" ]; then
    echo "Decrypted content is:"
    cat "${FILENAME}_decrypted.txt"
    rm -f "${FILENAME}.txt"
    rm -f "${FILENAME}_decrypted.txt"  # Optional: Remove the temporary decrypted file for security
else
    echo "Decryption failed or the file does not exist."
fi


