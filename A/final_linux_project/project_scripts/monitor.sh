#!/bin/bash

# Path to log file
LOG_FILE="/home/itai/final_linux_project/script_logs/monitor.log"
# Email configuration
EMAIL="recipient_email@example.com"
SUBJECT="System Alert"

# Function to log messages to the system log, custom log file, and send email
log_message() {
    local subject=$1
    local message=$2

    # Log the message to the system log
    logger -t monitor_script "$subject: $message"

    # Log the message to the custom log file
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $subject: $message" >> $LOG_FILE

    # Send the message via email
    echo "$message" | mail -s "$subject" $EMAIL
}

# Function to monitor system resources and processes
monitor_system() {
    local alert=false

    # CPU usage
    local cpu_percent=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if [ $cpu_percent -gt 90 ]; then
        local message="High CPU usage: $cpu_percent%"
        log_message "High CPU Usage Alert" "$message"
        alert=true
    fi

    # Memory usage
    local memory_percent=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    if [ $memory_percent -gt 90 ]; then
        local message="High memory usage: $memory_percent%"
        log_message "High Memory Usage Alert" "$message"
        alert=true

    # RAM usage in GB
    local ram_usage=$(free -h | awk '/Mem:/ { print $3 }')
    if [ ${ram_usage%G} -gt 90 ]; then
        local message="High RAM usage: $ram_usage"
        log_message "High RAM Usage Alert" "$message"
        alert=true
        
    # Check if cron scheduler is running
    if ! pgrep cron >/dev/null; then
        local message="Cron scheduler is not running"
        log_message "Cron Scheduler Failure Alert" "$message"
        alert=true
    fi

    # If no alerts were triggered, log that everything is fine
    if [ "$alert" = false ]; then
        log_message "System Status" "All systems are functioning within normal parameters."
    fi
}

# Start monitoring
monitor_system
