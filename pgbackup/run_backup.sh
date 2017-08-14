#!/bin/bash
# -*- mode: shell-script -*-

set -e  # <= 0以外が返るものがあったら止まる, 未定義の変数を使おうとしたときに打ち止め

echo db backup start `date +%Y%m%d_%H%M%S`

. /opt/env.sh
# export PGPASSWORD=${POSTGRES_PASSWORD}
export FILENAME=${BACKUP_FILE_PREFIX}-`date +%Y%m%d_%H%M%S`.${BACKUP_FILE_EXT}
# pg_dump -h db -d ${POSTGRES_DB} -U ${POSTGRES_USER} -w | gzip -c > /tmp/${FILENAME}

# CMD=`echo ${BACKUP_CMD} | envsubst`
# echo backup command ${CMD}
export BACKUP_FILENAME=/tmp/${FILENAME}
echo "backup command = ${BACKUP_CMD}"
eval ${BACKUP_CMD}

if [ ""${BACKUP_ENCRYPT_KEY} != "" ] ; then
    export GNUPGHOME=/tmp/
    echo -n ${BACKUP_ENCRYPT_KEY} | gpg --no-tty -o /tmp/${FILENAME}.gpg --cipher-algo AES256 --passphrase-fd 0 -c /tmp/${FILENAME}
    rm /tmp/${FILENAME}
    FILENAME=${FILENAME}.gpg
fi

if [ ""${BACKUP_AWS_ACCESS_KEY} != "" ] ; then
    export AWS_ACCESS_KEY_ID=${BACKUP_AWS_ACCESS_KEY}
    export AWS_SECRET_ACCESS_KEY=${BACKUP_AWS_SECRET_KEY}
    aws s3 cp /tmp/${FILENAME} s3://${BACKUP_AWS_BUCKET_NAME}/${BACKUP_AWS_BACKUP_DIR}/${FILENAME}
    rm /tmp/${FILENAME}
fi

echo "db backup end `date +%Y%m%d_%H%M%S` -> ${FILENAME}"
