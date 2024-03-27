#!/bin/bash

#RCLONE_SRC
#RCLONE_DST


RCLONE_CONFIG_FILE=${RCLONE_CONFIG_FILE:=/etc/rclone/rclone.conf}
if [ ! -f ${RCLONE_CONFIG_FILE} ]; then
  error "rclone configuration file '${RCLONE_CONFIG_FILE}' does not exist"
  exit -1
elif [ ! -r ${RCLONE_CONFIG_FILE} ]; then
  error "rclone configuration file '${RCLONE_CONFIG_FILE}' exists, but read permission is not granted"
  exit -2
fi

RCLONE_EXEC=${RCLONE_EXEC:=/usr/bin/rclone}
if [ ! -f ${RCLONE_EXEC} ]; then
  error "rclone executable file '${RCLONE_EXEC}' does not exist"
  exit -3
elif [ ! -r ${RCLONE_EXEC} ]; then
  error "rclone executable file '${RCLONE_EXEC}' exists, but read permission is not granted"
  exit -4
fi

RCLONE_CMD=${RCLONE_CMD:=sync}
if [[ ! ${RCLONE_CMD} =~ (copy|move|sync) ]]; then
  error "rclone command '${RCLONE_CMD}' is not supported by this container, please use sync/copy/move. Stopping."
  exit -5
fi

#RCLONE_CMD_OPTS

RCLONE_LOG_LEVEL=${RCLONE_LOG_LEVEL:=INFO}
if [[ ! ${RCLONE_LOG_LEVEL} =~ (NONE|DEBUG|INFO|NOTICE|ERROR) ]]; then
  error "rclone log level '${RCLONE_LOG_LEVEL}' is not supported by this container, please use NONE|DEBUG|INFO|NOTICE|ERROR. Stopping."
  exit -6
fi

RCLONE_LOG_ROTATE=${RCLONE_LOG_ROTATE:=30}
RCLONE_LOG_DIR=${RCLONE_LOG_DIR:=/var/log/rclone}
if [ ! -d ${RCLONE_LOG_DIR} ]; then
  error "rclone log directory '${RCLONE_LOG_DIR}' does not exist"
  exit -7
elif [ ! -w ${RCLONE_LOG_DIR} ]; then
  error "rclone log directory '${RCLONE_LOG_DIR}' exists, but write permission is not granted"
  exit -8
fi

if [ -z ${RCLONE_LOG_FILE:-} ]; then
  d=$(date +%Y_%m_%d-%H_%M_%S)
  RCLONE_LOG_FILE="${RCLONE_LOG_DIR}/rclone-$d.log"
  info "RCLONE_LOG_FILE was set to '${RCLONE_LOG_FILE}'"
fi

RCLONE_PID_DIR=${RCLONE_PID_DIR:=/var/run/rclone}
if [ ! -d ${RCLONE_PID_DIR} ]; then
  error "rclone pid directory '${RCLONE_PID_DIR}' does not exist"
  exit -10
elif [ ! -w ${RCLONE_PID_DIR} ]; then
  error "rclone pid directory '${RCLONE_PID_DIR}' exists, but write permission is not granted"
  exit -11
fi

if [ -z ${RCLONE_PID_FILE:-} ]; then
  RCLONE_PID_FILE="${RCLONE_PID_DIR}/rclone.pid"
  info "RCLONE_PID_FILE was set to '${RCLONE_PID_FILE}'"
fi

is_rclone_running() {
  if [ $(lsof | grep $0 | wc -l | tr -d ' ') -gt 1 ]
  then
    return 0
  else
    return 1
  fi
}

is_remote_exists() {
  local remote=$1

  if [ -z "${remote}" ]
  then
    return_code=1
  else
    CMD="${RCLONE_EXEC} lsf --max-depth 1 ${RCLONE_CMD_OPTS:-} '${remote}' --config ${RCLONE_CONFIG_FILE}"

    info "Executing: ${CMD}"
    set +e
    eval ${CMD}
    return_code=$?
    set -e
  fi

  return ${return_code}
}

rclone_cmd_exec() {
  CMD="${RCLONE_EXEC} ${RCLONE_CMD} ${RCLONE_CMD_OPTS} '${RCLONE_SRC}' '${RCLONE_DST}'"
  CMD="${CMD} --config '${RCLONE_CONFIG_FILE}'"
  CMD="${CMD} --log-file='${RCLONE_LOG_FILE}' --log-level ${RCLONE_LOG_LEVEL}"

  info "Executing: ${CMD}"
  info "Executing: ${CMD}" >> ${RCLONE_LOG_LEVEL}

  set +e
  eval ${CMD}
  return_code=$?
  set -e

  return ${return_code}
}

rotate_logs() {
  # Delete logs by user request
  if [ ! -z "${RCLONE_LOG_ROTATE##*[!0-9]*}" ]
  then
    info "Removing logs older than ${RCLONE_LOG_ROTATE} days" 
    touch ${RCLONE_LOG_DIR}/tmp.log
    find ${RCLONE_LOG_DIR}/*.log -mtime +${RCLONE_LOG_ROTATE} -type f -delete
    rm -f ${RCLONE_LOG_DIR}/tmp.log
  fi
}
