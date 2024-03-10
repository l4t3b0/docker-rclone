ARG BASE=alpine:latest
FROM ${BASE}

LABEL maintainer="l4t3b0@gmail.com"

ARG RCLONE_VERSION=v1.66.0
ARG ARCH=amd64

ENV RCLONE_SRC=

ENV RCLONE_CMD=sync
ENV RCLONE_CONFIG_DIR=/etc/rclone
ENV RCLONE_CONFIG_FILE=${RCLONE_CONFIG_DIR}/rclone.conf
ENV RCLONE_DST=/data
ENV RCLONE_EXEC=/usr/bin/rclone
ENV RCLONE_LOG_DIR=/var/log/rclone
ENV RCLONE_LOG_LEVEL=INFO
ENV RCLONE_LOG_ROTATE=30
ENV RCLONE_PID_DIR=/var/run/rclone
ENV RCLONE_PID_FILE=${RCLONE_PID_DIR}/rclone.pid

ENV CRON_EXPR=@weekly
ENV CRON_EXPR_ABORT=

ENV HEALTHCHECKS_IO_URL=

ENV TZ=
ENV PUID=0
ENV PGID=0

RUN apk --no-cache add bash ca-certificates dcron fuse tzdata wget

RUN URL=https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip ; \
  URL=${URL/\/current/} ; \
  cd /tmp \
  && wget -q $URL \
  && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
  && mv /tmp/rclone-*-linux-${ARCH}/rclone* /usr/bin \
  && rm -r /tmp/rclone*

RUN mkdir ${RCLONE_CONFIG_DIR}
RUN mkdir ${RCLONE_PID_DIR} && chown ${PUID}:${PGID} ${RCLONE_PID_DIR} && chmod 775 ${RCLONE_PID_DIR}
RUN mkdir ${RCLONE_LOG_DIR} && chown ${PUID}:${PGID} ${RCLONE_LOG_DIR} && chmod 775 ${RCLONE_LOG_DIR}

COPY --chmod=555 entrypoint.sh /
COPY --chmod=555 \
  crontab-helper.sh \
  environment.sh \
  healthchecks.io.sh \
  rclone.sh \
  rclone-sync.sh \
  rclone-sync-abort.sh \
  /usr/bin/

VOLUME ["/etc/rclone"]
VOLUME ["/var/log/rclone"]
VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
