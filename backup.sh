#!/bin/sh
# based from https://gist.github.com/eladnava/96bd9771cd2e01fb4427230563991c8d

# DB host
HOST=172.31.33.202
#HOST="$(hostname -I)"

# DB name
DBNAME=admin

# S3 bucket name
BUCKET=wizzard-dev-backup-repo-26092024

# Linux user account
USER=ssm-user

# Current time
DATE=`/bin/date +%d-%m-%Y_%H`

# Backup directory
DEST=/home/$USER/backup

# Tar file of backup directory
TAR=$DEST/$DATE.tar

# Create backup dir (-p to avoid warning if already exists)
#/bin/mkdir -p $DEST

# Log
echo "Backing up $HOST/$DBNAME to s3://$BUCKET/ on $DATE";

# Dump from mongodb host into backup directory
/usr/bin/mongodump --host="$HOST" --port=27017 --db=$DBNAME --out=$DEST --username=useradmin --password=kambusitis25011980 --authenticationDatabase=admin

# Create tar of backup directory
/bin/tar cvf $TAR -C $DEST .

# Upload tar to s3
/usr/bin/aws s3 cp $TAR s3://$BUCKET/

# Remove tar file locally
/bin/rm -f $TAR

# Remove backup directory
#/bin/rm -rf $DEST

# All done
echo "Backup available at https://s3.amazonaws.com/$BUCKET/$TIME.tar"