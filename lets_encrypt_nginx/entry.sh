#!/bin/bash
# -*- mode: shell-script -*-

set -e  # <= 0以外が返るものがあったら止まる

envsubst '$HOST$PORT$FQDN' < /etc/nginx/conf.d/app.conf.tmpl > /etc/nginx/conf.d/app.conf

function create_cert () {
    fqdn=$1
    password=test
    dirname=/etc/letsencrypt/live/${fqdn}
    path=/etc/letsencrypt/live/${fqdn}/tmp

    mkdir -p ${dirname}
    
    openssl genrsa -des3 -out ${path}.key -passout pass:${password} 2048
    openssl req -passin pass:${password} -new -key ${path}.key -out ${path}.csr  -subj "/CN=${fqdn}"
    cp ${path}.key ${path}.key.org
    openssl rsa -passin pass:${password} -in ${path}.key.org -out ${dirname}/privkey.pem
    openssl x509 -req -days 3650 -passin pass:${password} -in ${path}.csr -signkey ${path}.key -out ${dirname}/fullchain.pem
    chmod 600 ${dirname}/privkey.pem
    chmod 600 ${dirname}/fullchain.pem
}

hostname_array=()
for i in `cat /etc/nginx/conf.d/*.conf | awk 'match($0, /live\/.*\/fullchain.pem/) {print substr($0, RSTART+5, RLENGTH-19)}' | sort | uniq`; do
    if [ ! -e /etc/letsencrypt/live/${i}/fullchain.pem ]; then
        create_cert $i
        hostname_array+=( $i )
    fi
done


# if [[ ""$USE_LETS_ENCRYPT =~ ^[Yy]$ ]]; then
#     for i in hostname_array; do
#         certbot certonly --webroot --email dev@sizebook.co.jp --agree-tos -n -w /var/www/letsencrypt -d $i
#     done
# fi

rm -f /var/log/cron.log
rm -f /var/log/cron.err
mkfifo /var/log/cron.log
mkfifo /var/log/cron.err
tail -f /var/log/cron.log > /dev/stdout &
tail -f /var/log/cron.err > /dev/stderr &

# cp /opt/daily_backup.cron /etc/cron.d/backup; ; /bin/bash /opt/run_cron.sh
touch /etc/cron.d/schedule
cat /etc/cron.d/schedule > /var/spool/cron/crontabs/root
chmod 0644 /etc/cron.d/schedule
chown root:root -R /etc/cron.d
# chmod 0644 /var/spool/cron/crontabs/schedule
chown root:root -R /var/spool/cron/crontabs/
# crond -c /etc/cron.d/ -f -L /dev/stdout &
crond -f -l 0 &

nginx -g "daemon off;" &

tail -f /dev/null
