#!/bin/bash

# Log file path
LOG_FILE="/home/itai/final_linux_project/script_logs/backup.log"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Debug statement to verify script execution
echo "Script started"
log_message "Script started"

# Define source directories to be backed up
EDUCATION_DIR="/home/itai/personal_folder/Education"
DEVELOPMENT_DIR="/home/itai/personal_folder/Development"

# Define destination directory (external drive or another designated location)
DESTINATION_DIR="/home/itai/final_linux_project/backup_file"

# Ensure destination directory exists, create it if not
mkdir -p "$DESTINATION_DIR"

# Debug statement to verify destination directory creation
echo "Destination directory created"
log_message "Destination directory created"

# Function to backup each specified directory to the destination directory
backup_directory() {
    local source_dir="$1"
    
    # Check if the source directory exists
    if [ ! -d "$source_dir" ]; then
        echo "Error: $source_dir does not exist or is not a directory."
        log_message "Error: $source_dir does not exist or is not a directory."
        return 1
    fi
    
    # Extract the directory name from the full path
    local dir_name
    dir_name=$(basename "$source_dir")
    
    # Create a timestamp for the backup file name
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M)
    
    # Create the backup file name with directory name and timestamp
    local backup_file
    backup_file="${DESTINATION_DIR}/${dir_name}_${timestamp}.tar.gz"
    
    # Create a compressed archive of the source directory
    tar -czf "$backup_file" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>> "$LOG_FILE"
    
    # Check if tar command was successful
    if [ $? -eq 0 ]; then
        echo "Backup of $source_dir completed: $backup_file"
        log_message "Backup of $source_dir completed: $backup_file"
    else
        echo "Error: Backup of $source_dir failed."
        log_message "Error: Backup of $source_dir failed."
    fi
}

# Backup education directory
backup_directory "$EDUCATION_DIR"

# Backup development directory
backup_directory "$DEVELOPMENT_DIR"

# Debug statement to verify script completion
echo "Script completed"
log_message "Script completed"
