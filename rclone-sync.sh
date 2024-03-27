#!/bin/bash

unset RCLONE_JOBS_ARRAY
declare -A RCLONE_JOBS_ARRAY

function get_rclone_jobs() {
  if [ -z "${RCLONE_SRC:-}" -a -n "${RCLONE_DST:-}" ]; then
    info "RCLONE_SRC not defined. Stopping"
    exit 1
  elif [ -n "${RCLONE_SRC:-}" -a -z "${RCLONE_DST:-}" ]; then
    info "RCLONE_DST not defined. Stopping"
    exit 1
  elif [ -n "${RCLONE_SRC:-}" -a -n "${RCLONE_DST:-}" ]; then
    RCLONE_JOBS_ARRAY[0,0]=${RCLONE_SRC}
    RCLONE_JOBS_ARRAY[0,1]=${RCLONE_DST}
  else
    declare -i index=0

    for i in {0..31}
    do
      job_id=RCLONE_JOB_${i}
      if [ -n "${!job_id:-}" ]; then
        src=`echo ${!job_id} | cut -d'|' -f 1`
        dst=`echo ${!job_id} | cut -s -d'|' -f 2-`

        RCLONE_JOBS_ARRAY[${index},0]=${src}
        RCLONE_JOBS_ARRAY[${index},1]=${dst}

        ((index+=1))
      fi
    done
  fi
}

. output.sh
. rclone.sh
. healthchecks.io.sh

cleanup()
{
  local exit_code=$?

  info "Cleanup process initiated with return code: ${exit_code}"

  healthchecks_io_end ${exit_code}
}

info "Starting rclone-sync.sh pid $$ $(date)"

if is_rclone_running
then
  warn "A previous rclone instance is still running. Skipping new command."
else
  healthchecks_io_start
  trap cleanup ERR EXIT

  echo $$ > ${RCLONE_PID_FILE}
  debug "PID file created successfuly: ${RCLONE_PID_FILE}"

  rotate_logs

  get_rclone_jobs

  for ((i = 0; i < ${#RCLONE_JOBS_ARRAY[@]} / 2; i++)); do
    RCLONE_SRC="${RCLONE_JOBS_ARRAY[$i,0]}"
    RCLONE_DST="${RCLONE_JOBS_ARRAY[$i,1]}"

    if [ -z "${RCLONE_SRC}" ]; then
      warn "Ignoring invalid job definition: '${!job_id}'. source could not be determined"
    elif [ -z "${RCLONE_DST}" ]; then
      warn "Ignoring invalid job definition: '${!job_id}'. destination could not be determined"
    else
      if is_remote_exists ${RCLONE_SRC}
      then
        info "${RCLONE_CMD} from '${RCLONE_SRC}' to '${RCLONE_DST}'"

	if rclone_cmd_exec; then
          debug "rclone command finished successfully"
        else
          error "rclone command finished with error: $?"

          exit 1
        fi
      else
        error "Source directory \"${RCLONE_SRC}\" does not exists?"

	exit 1
      fi
    fi
  done

  debug "Removing PID file"
  rm -f ${RCLONE_PID_FILE}
fi
