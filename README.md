# Mysql dump to S3
A docker image for backup all mysql databases and upload them to a S3 Bucket.

Image runs as a cron job by default every hour. Period may be changed by tuning `BACKUP_CRON_SCHEDULE` environment variable.   
It also have a `BACKUP_PRIORITY` param for set the backup priority with ionice and nice values.   
May also be run as a one time backup job by using `backup.sh` script as command.
 

Following environment variables should be set for mysql to work:
```
MYSQL_HOST=mysql
MYSQL_PASSWORD=password
```

Following environment variables should be set for backup to work:
```
BACKUP_S3_BUCKET=		// no trailing slash at the end!
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

Flowing environment variables can be set to change the functionality:
```
BACKUP_CRON_SCHEDULE=* * * * *
MYSQL_BACKUP_DIR=/var/backup/mysql
MYSQL_EXCLUDE_DBS=|sys|mysql
BACKUP_PRIORITY=<this is the priority, standard value is "ionice -c 3 nice -n 10">
MYSQL_DUMP_PARAMS="--lock-tables=false --single-transaction --quick" 
```


If you want to keep the archive files created, mount a volume on `MYSQL_BACKUP_DIR`.

If you want to store files on S3 under a subdirectory, just add it to the `BACKUP_S3_BUCKET` like `BACKUP_S3_BUCKET=bucket_name/subdirectory_for_storage`.
