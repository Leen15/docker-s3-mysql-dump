#!/bin/bash
# Inspired by https://github.com/iainmckay/docker-mysql-backup

set -e

EXCLUDE_OPT=
PASS_OPT=

for i in "$@"; do
    case $i in
        --exclude=*)
        EXCLUDE_OPT="${i#*=}"
        shift
        ;;
        *)
            # unknown option
        ;;
    esac
done


echo "backup started at $(date +%Y-%m-%d_%H:%M:%S)"
mkdir -p $MYSQL_BACKUP_DIR


if [ -n $MYSQL_PASSWORD ]; then
    PASS_OPT="--password=${MYSQL_PASSWORD}"
fi

MYSQL_CONN="--user=$MYSQL_USER --host=$MYSQL_HOST --port=$MYSQL_PORT ${PASS_OPT}"

if [ -n $EXCLUDE_OPT ]; then
    EXCLUDE_OPT="| grep -Ev (${EXCLUDE_OPT//,/|})"
fi

if [ -n "$2" ]; then
    databases=$2
else
	echo "Finding databases..."
    databases=`mysql ${MYSQL_CONN} -N -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema)${EXCLUDE_OPT}"`
fi

for db in $databases; do
    echo "Dumping: $db..."
    if [ -n "$DUMP_TIMESTAMP" ]; then
    	timestamp=`date +%Y-%m-%d.%H%M%S`
    	filename="${db}_${timestamp}"
    else
    	filename=$db
    fi
    mysqldump --force --events --opt ${MYSQL_CONN} --databases $db | gzip > "$MYSQL_BACKUP_DIR/$filename.gz"
done


echo "uploading databases to s3..."
   #echo "archive created, uploading..."
/usr/bin/aws s3 sync ${MYSQL_BACKUP_DIR} s3://${BACKUP_S3_BUCKET}

echo "backup finished at $(date +%Y-%m-%d_%H:%M:%S)"
