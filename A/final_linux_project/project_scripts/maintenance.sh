#!/bin/bash

# This script cleans up temporary files and old logs.
# Temporary files are deleted after 7 days.
# Log files older than 30 days are removed.

# Define variables
TEMP_DIR="/tmp"
LOG_DIR="/var/log"
TEMP_RETENTION_DAYS=7
LOG_RETENTION_DAYS=30
# Log file path
LOG_FILE="/home/itai/final_linux_project/script_logs/maintenance.log" 

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
    echo "$message"
}

# Function to remove temporary files
cleanup_temp_files() {
    log_message "Cleaning up temporary files..."
    find "$TEMP_DIR" -type f -mtime +$TEMP_RETENTION_DAYS -delete 2>/dev/null
    log_message "Temporary files older than $TEMP_RETENTION_DAYS days are removed."
}

# Function to remove old log files
cleanup_old_logs() {
    log_message "Cleaning up old log files..."
    find "$LOG_DIR" -type f -name '*.log' -mtime +$LOG_RETENTION_DAYS -delete 2>/dev/null
    log_message "Log files older than $LOG_RETENTION_DAYS days are removed."
}

# Main function
main() {
    cleanup_temp_files || log_message "Failed to clean up temporary files."
    cleanup_old_logs || log_message "Failed to clean up old log files."
}

# Run the main function
main

exit 0
