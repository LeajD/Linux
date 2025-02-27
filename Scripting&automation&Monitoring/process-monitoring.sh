
#!/bin/bash
# Process Monitoring & Management Project for DevOps Portfolio
# Author: Your Name
# Description: Monitors critical processes, logs resource usage, and alerts if thresholds are exceeded.

LOG_FILE="/var/log/process_monitor.log"
ALERT_THRESHOLD=80  # CPU usage percentage threshold for alerts
ALERT_RECIPIENT="your_email@example.com"

# Function to check if a critical process is running
check_process() {
    local process_name="$1"
    if pgrep -x "$process_name" > /dev/null; then
        echo "[$(date)] Process '$process_name' is running." >> "$LOG_FILE"
    else
        echo "[$(date)] ALERT: Process '$process_name' is not running! Restarting..." | tee -a "$LOG_FILE"
        systemctl restart "$process_name"
    fi
}

# Function to log CPU and memory usage
log_resource_usage() {
    echo "[$(date)] Resource Usage:" >> "$LOG_FILE"
    ps aux --sort=-%cpu | head -10 >> "$LOG_FILE"
    echo "---------------------------------------------------" >> "$LOG_FILE"
}

# Function to check CPU usage and send alert
check_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    if (( $(echo "$cpu_usage > $ALERT_THRESHOLD" | bc -l) )); then
        echo "[$(date)] ALERT: CPU usage is above $ALERT_THRESHOLD%! Current: $cpu_usage%" | tee -a "$LOG_FILE"
        echo "CPU usage alert! Current: $cpu_usage%" | mail -s "High CPU Usage Alert" "$ALERT_RECIPIENT"
    fi
}

# Main monitoring loop
while true; do
    check_process "nginx"  # Replace with your critical process
    check_process "mysqld"
    log_resource_usage
    check_cpu_usage
    sleep 60  # Check every 60 seconds
done
