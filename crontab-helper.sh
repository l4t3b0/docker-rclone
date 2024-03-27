#!/bin/bash

. output.sh

crontab_add() {
  local cron_expr=$1
  local cron_command=$2
  local tmp_file=/tmp/crontab.tmp

  case "$(echo "${cron_expr}" | tr '[:lower:]' '[:upper:]')" in
    *@YEARLY* ) info "Cron expression ${cron_expr} re-written to 0 0 1 1 *" && cron_expr="0 0 1 1 *";;
    *@ANNUALLY* ) info "Cron expression ${CRON_EXPR} re-written to 0 0 1 1 *" && cron_expr="0 0 1 1 *";;
    *@MONTHLY* ) info "Cron expression ${cron_expr} re-written to 0 0 1 * *" && cron_expr="0 0 1 * * ";;
    *@WEEKLY* ) info "Cron expression ${cron_expr} re-written to 0 0 * * 0" && cron_expr="0 0 * * 0";;
    *@DAILY* ) info "Cron expression ${cron_expr} re-written to 0 0 * * *" && cron_expr="0 0 * * *";;
    *@MIDNIGHT* ) info "Cron expression ${cron_expr} re-written to 0 0 * * *" && cron_expr="0 0 * * *";;
    *@HOURLY* ) info "Cron expression ${cron_expr} re-written to 0 * * * *" && cron_expr="0 * * * *";;
    *@* ) warn "WARNING: Cron expression ${cron_expr} is not supported. Stopping." && exit 1;;
  esac

  echo "${cron_expr} ${cron_command}" > ${tmp_file}
  debug "adding the following line to the crontab: `cat ${tmp_file}`;"
  crontab ${tmp_file}

  rm ${tmp_file}
}

crond_start() {
  rm -f /tmp/crond.log

  info "Starting crond ..."
  crond -b -l 0 -L /tmp/crond.log
  info "crond started"
}

crond_tail() {
  tail -F /tmp/crond.log
}
