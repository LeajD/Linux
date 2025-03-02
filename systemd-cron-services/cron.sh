#backups automation daily at 2:00 AM
0 2 * * * rsync -avz /home /etc /var user@backup_server:/backups/$(date +\%F).tar.gz

#update and upgrade packages every Sunday at 3:00 AM
0 3 * * SUN apt-get update && apt-get upgrade -y

#logrotate every day at midnight
0 1 * * * /usr/sbin/logrotate /etc/logrotate.conf

#monitor disk usage every hour
0 * * * * /bin/bash /opt/scripts/check_disk_usage.sh

#/opt/scripts/check_disk_usage.sh
THRESHOLD=80
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if [ $DISK_USAGE -gt $THRESHOLD ]; then
    echo "Disk usage is over ${THRESHOLD}% on $(hostname)" | mail -s "Disk Space Alert" admin@example.com
fi

# monitor user activity every hour
0 * * * * /bin/bash /opt/scripts/monitor_user_activity.sh

#/opt/scripts/monitor_user_activity.sh
last | head -n 10 > /var/log/user_activity.log
