#!/bin/bash

# set necessary env variables as globals
set | grep "BACKUP_" > /etc/environment
set | grep "AWS_" >> /etc/environment
set | grep "MYSQL_" >> /etc/environment

# change cron schedule
sed -i "s,CRON_SCHEDULE*,${BACKUP_CRON_SCHEDULE},g" /etc/cron.d/backup-cron

# run cron and observe logs
cron && tail -f /var/log/cron.log
