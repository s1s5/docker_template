FROM postgres:9.6.2

RUN apt-get update && apt-get install -y --no-install-recommends python-pip && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install awscli

COPY run_cron.sh /opt/
COPY run_backup.sh /opt/
ENV CRON_FILE /opt/cron
ENV BACKUP_CMD 'export PGPASSWORD=${POSTGRES_PASSWORD}; pg_dump -h db -d ${POSTGRES_DB} -U ${POSTGRES_USER} -w | bzip2 -9 -c > ${BACKUP_FILENAME}'
ENV BACKUP_FILE_PREFIX ecms
ENV BACKUP_FILE_EXT sql.bz2
RUN echo "14 5 * * * /bin/bash /opt/run_backup.sh >> /var/log/cron.log 2>> /var/log/cron.err" > ${CRON_FILE}

CMD ["/opt/run_cron.sh"]
