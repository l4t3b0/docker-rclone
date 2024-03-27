#!/bin/bash

. output.sh

if [ ! -z "${PGID}" ]; then
  GROUP=$(getent group "${PGID}" | cut -d: -f1)

  if [ -z "${GROUP}" ]; then
    if [ -z "${DEFAULT_GROUP}" ]; then
      error "Group with id ${PGID} does not exists. Environment variable 'DEFAULT_GROUP' must exists to define the groupname to create"
      exit -100
    else
      GROUP=${DEFAULT_GROUP}
    fi
    
    addgroup --gid "${PGID}" "$GROUP"

    info "Group '${GROUP}' (${PGID}) created successfully"
  else
    info "Group '${GROUP}' (${PGID}) will be used"
  fi
fi

if [ -z "${PUID}" ]
then
  USER=$(whoami)
else
  USER=$(getent passwd "${PUID}" | cut -d: -f1)

  if [ -z "${USER}" ]; then
    if [ -z "${DEFAULT_USER}" ]; then
      error "User with id ${PUID} does not exists. Environment variable 'DEFAULT_USER' must exists to define the username to create"
      exit -101
    else
      USER=${DEFAULT_USER}
    fi

    adduser \
      --disabled-password \
      --gecos "" \
      --no-create-home \
      --ingroup "${GROUP}" \
      --uid "${PUID}" \
      "$USER" > /dev/null

    info "User '${USER}' (${PUID}) with group '${GROUP}' created successfully"
  else
    debug "User '${USER}' (${PUID}) will be used"
  fi
fi

# Set time zone if passed in
if [ -z "${TZ:-}" ]; then
  info "No timezone is defined. Using default"
else
  cp /usr/share/zoneinfo/${TZ} /etc/localtime
  echo ${TZ} > /etc/timezone

  debug "Timezone '${TZ}' is set"
fi
