#!/bin/sh

. logging.sh

healthchecks_io_start() {
  local url

  if [ ! -z "${HEALTHCHECKS_IO_URL:-}" ]
  then
    url=${HEALTHCHECKS_IO_URL}/start
    info "Sending helatchecks.io start signal to '${url}'"

    wget ${url} -O /dev/null
  fi
}

healthchecks_io_end() {
  local return_code=$1
  local url

  # Wrap up healthchecks.io call with complete or failure signal
  if [ ! -z "${HEALTHCHECKS_IO_URL}" ]
  then
    if [ "${return_code}" == 0 ]
    then
      url=${HEALTHCHECKS_IO_URL}
      info "Sending helatchecks.io complete signal to '${url}'"
    else
      url=${HEALTHCHECKS_IO_URL}/fail
      warn "Sending helatchecks.io failure signal to '${url}'"
    fi

    wget ${url} -O /dev/null
  fi
}
