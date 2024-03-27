#!/bin/sh

. logging.sh

call_webhook(){
  [[ -z "$1" ]] && return 0
  [[ ! "$1" == "http"* ]] && return 0
  if curl curl --connect-timeout 5 --max-time 10 --retry 3 -s "$1" > /dev/null ; then
    debug "Call webhook to [$1]: OK"
  else
    debug "Call webhook to [$1]: FAILED"
  fi
}

healthchecks_io_start() {
  local url

  if [ ! -z "${HEALTHCHECKS_IO_URL:-}" ]
  then
    url=${HEALTHCHECKS_IO_URL}/start
    info "Sending helatchecks.io start signal to '${url}'"

    call_webhook ${url}
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
      url=${HEALTHCHECKS_IO_URL}/${return_code}
      warn "Sending helatchecks.io failure signal to '${url}'"
    fi

    call_webhook ${url}
  fi
}
