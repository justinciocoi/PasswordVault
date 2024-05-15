#!/bin/bash

# Check for a saved configuration file
CONFIG_FILE="$HOME/.password_decrypt_config"

KEY_FOLDER="$HOME/.key"
AES_KEY_FILE="aes_key.txt"

if [ -d "$KEY_FOLDER" ] && [ -f "$KEY_FOLDER/$AES_KEY_FILE" ]; then
    echo "AES key file found."
    AES_KEY_PATH="$KEY_FOLDER/$AES_KEY_FILE"
else
    echo "AES key file not found in the .key folder."
    ###HERE ASK IF WE SHOULD MAKE A NEW ONE OR SET A NEW PATH
    read -p "Enter the full path to your AES key: " AES_KEY_PATH
fi

if [ -f "$CONFIG_FILE" ]; then
    read -p "Found a saved configuration. Would you like to use it? (y/n): " USE_SAVED
    if [[ $USE_SAVED =~ ^[Yy]$ ]]; then
        echo "Loading saved configuration..."
        source "$CONFIG_FILE"
    else
        # Prompt the user for details if they choose not to use the saved config
        read -p "Enter the full path for your vault directory: " LOCAL_DIR
        read -p "Enter the full path to your AES key: " AES_KEY_PATH

        # Ask if the user wants to save these details for future use
        read -p "Would you like to save these details for future use? (y/n): " SAVE_CHOICE
        if [[ $SAVE_CHOICE =~ ^[Yy]$ ]]; then
            echo "Saving configuration..."
            echo "LOCAL_DIR='$LOCAL_DIR'" > "$CONFIG_FILE" # Overwrite or create new file
            echo "AES_KEY_PATH='$AES_KEY_PATH'" >> "$CONFIG_FILE"
        fi
    fi
else
    # Prompt the user for details if no saved config exists
    read -p "Enter the full path for your vault directory: " LOCAL_DIR

    # Ask if the user wants to save these details for future use
    read -p "Would you like to save these details for future use? (y/n): " SAVE_CHOICE
    if [[ $SAVE_CHOICE =~ ^[Yy]$ ]]; then
        echo "Saving configuration..."
        echo "LOCAL_DIR='$LOCAL_DIR'" > "$CONFIG_FILE" # Overwrite or create new file
        echo "AES_KEY_PATH='$AES_KEY_PATH'" >> "$CONFIG_FILE"
    fi
fi

# Prompt the user to enter the file to be decrypted
read -p "Enter the file name you wish to decrypt (include file extension (.txt)): " ENCRYPTED_FILE
echo # move to a new line

# Decrypt the password
output=$(openssl enc -aes-256-cbc -d -a -salt -pbkdf2 -iter 10000 -pass file:$AES_KEY_PATH -in "$ENCRYPTED_FILE" 2>&1)

if [ $? -eq 0 ]; then
    echo "Decrypted content is:"
    echo "$output"
else
    echo "An error occurred during the decryption. Error details: $output"
fi
