#!/bin/bash

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

  if is_remote_exists ${RCLONE_SRC}
  then
    rclone_cmd_exec

    return_code=$?
  else
    echo "WARNING: Source directory \"${RCLONE_SRC}\" does not exists."

    return_code=1
  fi

  healthchecks_io_end ${return_code}

  echo "INFO: Removing PID file"
  rm -f ${RCLONE_PID_FILE}
fi
