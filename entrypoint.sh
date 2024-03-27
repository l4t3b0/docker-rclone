#!/bin/bash

# set strict mode -  via http://redsymbol.net/articles/unofficial-bash-strict-mode/
# removed -e because it made basic [[ testing ]] difficult
set -euo pipefail
IFS=$'\n\t'

DEFAULT_USER=rclone
DEFAULT_GROUP=rclone

. /usr/bin/output.sh
. /usr/bin/crontab-helper.sh
. /usr/bin/environment.sh
. /usr/bin/healthchecks.io.sh

cleanup()
{
  healthchecks_io_end ${return_code}
}

rm -f /tmp/sync.pid

if is_rclone_running
then
  warn "A previous rclone instance is still running. Skipping new command."
else
  # Announce version
  info "Running $(rclone --version | head -n 1)"

  echo $$ > ${RCLONE_PID_FILE}
  debug "PID file created successfuly: ${RCLONE_PID_FILE}"

  healthchecks_io_start
  trap cleanup ERR

  if [ -z "${SYNC_ON_STARTUP}" ]
  then
    warn "Set SYNC_ON_STARTUP environment variable to perform a sync on startup"
  else
    su "${USER}" -c /usr/bin/rclone-sync.sh
  fi

  if [ -z ${CRON_EXPR} ]; then
    info "Environment variable 'CRON_EXPR' is not set. No crontab will be defined."
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
fi

