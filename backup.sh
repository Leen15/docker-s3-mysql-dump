#!/bin/bash
# Inspired by https://github.com/iainmckay/docker-mysql-backup

set -e

echo "backup started at $(date +%Y-%m-%d_%H:%M:%S)"
mkdir -p $MYSQL_BACKUP_DIR


MYSQL_CONN="--user=$MYSQL_USER --host=$MYSQL_HOST --port=$MYSQL_PORT --password=${MYSQL_PASSWORD}"

if [ -n "$2" ]; then
    databases=$2
else
	echo "Finding databases on host $MYSQL_HOST..."
    databases=`mysql ${MYSQL_CONN} -N -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema${MYSQL_EXCLUDE_DBS})"`
fi

for db in $databases; do
    echo "Dumping: $db..."
    if [ -n "$BACKUP_TIMESTAMP" ]; then
    	timestamp=`date +%Y-%m-%d.%H%M%S`
    	filename="${db}_${timestamp}"
    else
    	filename=$db
    fi
    $BACKUP_PRIORITY mysqldump --force --events --opt $MYSQL_DUMP_PARAMS ${MYSQL_CONN} --databases $db > "$MYSQL_BACKUP_DIR/$filename"
    echo "Compressing: $db..."
    $BACKUP_PRIORITY gzip -f "$MYSQL_BACKUP_DIR/$filename" > "$MYSQL_BACKUP_DIR/$filename.gz"
done


echo "uploading databases to s3..."
   #echo "archive created, uploading..."
/usr/bin/aws s3 sync ${MYSQL_BACKUP_DIR} s3://${BACKUP_S3_BUCKET}

echo "backup finished at $(date +%Y-%m-%d_%H:%M:%S)"
