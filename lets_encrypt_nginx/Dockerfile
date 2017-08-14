FROM nginx:alpine

RUN apk add --no-cache bash certbot openssl apk-cron

RUN mkdir -p /var/www/letsencrypt
RUN mkdir -p /etc/letsencrypt/key
RUN mkdir -p /etc/letsencrypt/csr
RUN mkdir -p /etc/letsencrypt/live

ADD conf.d/app.conf /etc/nginx/conf.d/app.conf.tmpl
COPY nginx.conf /etc/nginx/nginx.conf
COPY entry.sh /opt/_entry.sh

RUN mkdir -p /etc/cron.d
RUN echo '4 30 * * * /bin/bash -c "sleep $(($(od -vAn -tu2 -N2 /dev/urandom)  % 7200)); certbot renew; nginx -s reload" >> /var/log/cron.log 2>> /var/log/cron.err' > /etc/cron.d/schedule
RUN echo 'rm -rf /etc/letsencrypt/live/${1}; certbot certonly --webroot --email dev@sizebook.co.jp --agree-tos -n -w /var/www/letsencrypt -d ${1}; nginx -s reload' > /opt/init.sh
RUN chmod +x /opt/init.sh

VOLUME /var/www/letsencrypt
VOLUME /etc/letsencrypt

ENTRYPOINT ["/bin/bash"]
CMD ["/opt/_entry.sh"]
