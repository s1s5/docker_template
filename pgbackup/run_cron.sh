#!/bin/bash
# -*- mode: shell-script -*-

set -eu  # <= 0以外が返るものがあったら止まる, 未定義の変数を使おうとしたときに打ち止め
#     m h dom mon dow user command
# echo '* *   *   *   * app /bin/bash /opt/run_backup.sh > /dev/stdout 2> /dev/stderr' >> /etc/crontab
# whoami > /tmp/whoami_result
# sleep 30 && echo '* *   *   *   * /bin/bash /var/log/cron.log > /var/log/cron.log 2> /dev/stderr' | crontab &

crontab < ${CRON_FILE}
# cp ${CRON_FILE} /etc/cron.d/cron
# chmod 0644 /etc/cron.d/cron
# chown root:root -R /etc/cron.d

python -c "import sys, os; [sys.stdout.write('export {}={}\n'.format(x[0], repr(x[1]))) for x in os.environ.items() if ':' not in x[0]]" > /opt/env.sh
# chown app:app /opt/env.sh

rm -f /var/log/cron.log
rm -f /var/log/cron.err
mkfifo /var/log/cron.log
mkfifo /var/log/cron.err
tail -f /var/log/cron.log > /dev/stdout &
tail -f /var/log/cron.err > /dev/stderr &

echo " - start cron - "
cat ${CRON_FILE}

cron -f
