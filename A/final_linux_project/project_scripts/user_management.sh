#!/bin/bash

LOG_FILE="/home/itai/final_linux_project/script_logs/user_management.log"
BASE_DIR="/home/itai/personal_folder"
MIN_PASSWORD_LENGTH=3  # Adjusted as needed

# Ensure the log file directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    local MESSAGE=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $MESSAGE" >> "$LOG_FILE"
}

# Function to create a user and set permissions
create_user() {
    local USERNAME=$1
    local PASSWORD=$2
    local GROUP=$3
    local FOLDER=$4

    log_message "Starting creation of user $USERNAME with group $GROUP and folder $FOLDER"

    # Check if password meets minimum length requirement
    if [ ${#PASSWORD} -lt $MIN_PASSWORD_LENGTH ]; then
        echo "ERROR: The password must be at least $MIN_PASSWORD_LENGTH characters long."
        log_message "ERROR: The password for user $USERNAME is too short."
        exit 1
    fi

    # Create group if it does not exist
    if ! getent group "$GROUP" > /dev/null; then
        if sudo groupadd "$GROUP"; then
            log_message "Created group $GROUP"
        else
            log_message "Failed to create group $GROUP"
            echo "Failed to create group $GROUP"
            exit 1
        fi
    else
        log_message "Group $GROUP already exists"
    fi

    # Create user and add to group
    if sudo useradd -m -G "$GROUP" -s /bin/bash "$USERNAME"; then
        echo "$USERNAME:$PASSWORD" | sudo passwd
        if [ $? -eq 0 ]; then
            log_message "Created user $USERNAME and added to group $GROUP"
        else
            log_message "Failed to set password for user $USERNAME"
            echo "Failed to set password for user $USERNAME"
            sudo userdel "$USERNAME"  # Cleanup user if password setting fails
            exit 1
        fi
    else
        log_message "Failed to create user $USERNAME"
        echo "Failed to create user $USERNAME"
        exit 1
    fi

    # Set the correct permissions for the user's folder
    if sudo chown itai:"$GROUP" "$BASE_DIR/$FOLDER"; then
        log_message "Changed ownership of $BASE_DIR/$FOLDER to itai:$GROUP"
    else
        log_message "Failed to change ownership of $BASE_DIR/$FOLDER"
        echo "Failed to change ownership of $BASE_DIR/$FOLDER"
        exit 1
    fi

    if sudo chmod 770 "$BASE_DIR/$FOLDER"; then
        log_message "Set permissions 770 on $BASE_DIR/$FOLDER"
    else
        log_message "Failed to set permissions on $BASE_DIR/$FOLDER"
        echo "Failed to set permissions on $BASE_DIR/$FOLDER"
        exit 1
    fi

    # Set read-only permissions for other folders
    for OTHER_FOLDER in "Development" "Education" "Personal"; do
        if [ "$OTHER_FOLDER" != "$FOLDER" ]; then
            if sudo setfacl -m u:"$USERNAME":r-x "$BASE_DIR/$OTHER_FOLDER"; then
                log_message "Set read-only access for $USERNAME on $BASE_DIR/$OTHER_FOLDER"
            else
                log_message "Failed to set read-only access for $USERNAME on $BASE_DIR/$OTHER_FOLDER"
                echo "Failed to set read-only access for $USERNAME on $BASE_DIR/$OTHER_FOLDER"
            fi
        fi
    done

    # Log the creation of the user
    log_message "Successfully created user $USERNAME with access to $FOLDER folder"
}

# Main menu
echo "Select the type of user to create:"
echo "1. Education"
echo "2. Development"
echo "3. Personal"
read -p "Enter your choice (1/2/3): " CHOICE
read -p "Enter the username: " USERNAME
read -sp "Enter the password: " PASSWORD
echo

log_message "User creation process started for $USERNAME with choice $CHOICE"

case $CHOICE in
    1)
        GROUP="Education_group"
        FOLDER="Education"
        ;;
    2)
        GROUP="Development_group"
        FOLDER="Development"
        ;;
    3)
        GROUP="Personal_group"
        FOLDER="Personal"
        ;;
    *)
        log_message "Invalid choice: $CHOICE"
        echo "Invalid choice!"
        exit 1
        ;;
esac

# Check if the directory exists
if [ ! -d "$BASE_DIR/$FOLDER" ]; then
    echo "Directory $BASE_DIR/$FOLDER does not exist!"
    log_message "Directory $BASE_DIR/$FOLDER does not exist for user $USERNAME"
    exit 1
fi

create_user "$USERNAME" "$PASSWORD" "$GROUP" "$FOLDER"
log_message "User $USERNAME created and added to $GROUP with access to $FOLDER folder"
echo "User $USERNAME created and added to $GROUP with access to $FOLDER folder."
