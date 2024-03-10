#!/bin/bash

crontab_add() {
  local cron_expr=$1
  local cron_command=$2
  local tmp_file=/tmp/crontab.tmp

  case "$(echo "${cron_expr}" | tr '[:lower:]' '[:upper:]')" in
    *@YEARLY* ) echo "INFO: Cron expression ${cron_expr} re-written to 0 0 1 1 *" && cron_expr="0 0 1 1 *";;
    *@ANNUALLY* ) echo "INFO: Cron expression ${CRON_EXPR} re-written to 0 0 1 1 *" && cron_expr="0 0 1 1 *";;
    *@MONTHLY* ) echo "INFO: Cron expression ${cron_expr} re-written to 0 0 1 * *" && cron_expr="0 0 1 * * ";;
    *@WEEKLY* ) echo "INFO: Cron expression ${cron_expr} re-written to 0 0 * * 0" && cron_expr="0 0 * * 0";;
    *@DAILY* ) echo "INFO: Cron expression ${cron_expr} re-written to 0 0 * * *" && cron_expr="0 0 * * *";;
    *@MIDNIGHT* ) echo "INFO: Cron expression ${cron_expr} re-written to 0 0 * * *" && cron_expr="0 0 * * *";;
    *@HOURLY* ) echo "INFO: Cron expression ${cron_expr} re-written to 0 * * * *" && cron_expr="0 * * * *";;
    *@* ) echo "WARNING: Cron expression ${cron_expr} is not supported. Stopping." && exit 1;;
  esac

  echo "${cron_expr} ${cron_command}" > ${tmp_file}
  echo "DEBUG: adding the following line to the crontab: `cat ${tmp_file}`;"
  crontab ${tmp_file}

  rm ${tmp_file}
}

crond_start() {
  rm -f /tmp/crond.log

  echo "INFO: Starting crond ..."
  crond -b -l 0 -L /tmp/crond.log
  echo "INFO: crond started"
}

crond_tail() {
  tail -F /tmp/crond.log
}
