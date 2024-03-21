#!/bin/bash

unset RCLONE_JOBS_ARRAY
declare -A RCLONE_JOBS_ARRAY

function get_rclone_jobs() {
  if [ -z "${RCLONE_SRC}" -a -n "${RCLONE_DST}" ]; then
    echo "INFO: RCLONE_SRC not defined. Stopping"
    exit 1
  elif [ -n "${RCLONE_SRC}" -a -z "${RCLONE_DST}" ]; then
    echo "INFO: RCLONE_DST not defined. Stopping"
    exit 1
  elif [ -n "${RCLONE_SRC}" -a -n "${RCLONE_DST}" ]; then
    RCLONE_JOBS_ARRAY[0,0]=${RCLONE_SRC}
    RCLONE_JOBS_ARRAY[0,1]=${RCLONE_DST}
  else
    declare -i index=0

    for i in {0..31}
    do
      job_id=RCLONE_JOB_${i}
      if [ -n "${!job_id}" ]; then
        src=`echo ${!job_id} | cut -d'|' -f 1`
        dst=`echo ${!job_id} | cut -s -d'|' -f 2-`

        RCLONE_JOBS_ARRAY[${index},0]=${src}
        RCLONE_JOBS_ARRAY[${index},1]=${dst}

        ((index+=1))
      fi
    done
  fi
}

. rclone.sh
. healthchecks.io.sh

set -e

echo "INFO: Starting sync.sh pid $$ $(date)"

if is_rclone_running
then
  echo "WARNING: A previous rclone instance is still running. Skipping new command."
else
  echo $$ > ${RCLONE_PID_FILE}
  echo "INFO: PID file created successfuly: ${RCLONE_PID_FILE}"

  healthchecks_io_start

  rotate_logs

  get_rclone_jobs

  for ((i = 0; i < ${#RCLONE_JOBS_ARRAY[@]} / 2; i++)); do
    RCLONE_SRC="${RCLONE_JOBS_ARRAY[$i,0]}"
    RCLONE_DST="${RCLONE_JOBS_ARRAY[$i,1]}"

    if [ -z "${RCLONE_SRC}" ]; then
      echo "WARN: Ignoring invalid job definition: '${!job_id}'. source could not be determined"
    elif [ -z "${RCLONE_DST}" ]; then
      echo "WARN: Ignoring invalid job definition: '${!job_id}'. destination could not be determined"
    else
      if is_remote_exists ${RCLONE_SRC}
      then
        echo "${RCLONE_CMD} from '${RCLONE_SRC}' to '${RCLONE_DST}'"
#        rclone_cmd_exec

#        return_code=$?
      else
        echo "WARNING: Source directory \"${RCLONE_SRC}\" does not exists."

#        return_code=1
      fi
    fi
  done

  healthchecks_io_end ${return_code}

  echo "INFO: Removing PID file"
  rm -f ${RCLONE_PID_FILE}
fi
