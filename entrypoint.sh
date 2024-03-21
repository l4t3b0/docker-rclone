#!/bin/bash

set -e

DEFAULT_USER=rclone
DEFAULT_GROUP=rclone
. /usr/bin/environment.sh

. /usr/bin/crontab-helper.sh


rm -f /tmp/sync.pid

# Announce version
echo "INFO: Running $(rclone --version | head -n 1)"

if [ -z "${SYNC_ON_STARTUP}" ]
then
  echo "INFO: Set SYNC_ON_STARTUP environment variable to perform a sync on startup"
else
  su "${USER}" -c /usr/bin/rclone-sync.sh
fi

if [ -z ${CRON_EXPR} ]; then
  echo "INFO: Environment variable 'CRON_EXPR' is not set. No crontab will be defined."
else
  declare -r crontab_log_file=${RCLONE_LOG_DIR}/rclone-sync.crontab.log

  crontab_expr=${CRON_EXPR}
  crontab_command="su ${USER} -c /usr/bin/rclone-sync.sh >> ${crontab_log_file} 2>&1 > /tmp/crontab.tmp"
  crontab_add "${crontab_expr}" "${crontab_command}"

  crontab_expr=${CRON_ABORT_EXPR:=0 6 * * *}
  crontab_command="su ${USER} -c /usr/bin/rclone-sync-abort.sh >> ${crontab_log_file} 2>&1 >> /tmp/crontab.tmp"
  crontab_add "${crontab_expr}" "${crontab_command}"

  crond_start
  crond_tail
fi
