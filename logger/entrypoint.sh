#!/bin/bash
# -*- mode: shell-script -*-

# set -eu  # <= 0以外が返るものがあったら止まる, 未定義の変数を使おうとしたときに打ち止め

envsubst < /fluentd/etc/fluent.conf.template > /fluentd/etc/fluent.conf
echo -n ${FLUENT_SERVER_CRT} > /fluentd/etc/server.crt

uid=${FLUENT_UID:-1000}

# check if a old fluent user exists and delete it
cat /etc/passwd | grep fluent
if [ $? -eq 0 ]; then
    deluser fluent
fi

# (re)add the fluent user with $FLUENT_UID
useradd -u ${uid} -o -c "" -m fluent
export HOME=/home/fluent

# chown home and data folder
chown -R fluent:fluent /opt
chown -R fluent:fluent /home/fluent
chown -R fluent:fluent /fluentd

gosu fluent "$@"
