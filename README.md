# docker-rclone

Docker image to perform a [rclone](http://rclone.org) sync based on a cron schedule, with [healthchecks.io](https://healthchecks.io) monitoring.

rclone is a command line program to sync files and directories to and from:

* Google Drive
* Amazon S3
* Openstack Swift / Rackspace cloud files / Memset Memstore
* Dropbox
* Google Cloud Storage
* Amazon Drive
* Microsoft OneDrive
* Hubic
* Backblaze B2
* Yandex Disk
* SFTP
* FTP
* HTTP
* The local filesystem

## Usage

### Configure rclone

rclone needs a configuration file where credentials to access different storage
provider are kept.

By default, this image uses a file `/etc/rclone/rclone.conf` and a mounted volume may be used to keep that information persisted.

A first run of the container can help in the creation of the file, but feel free to manually create one.

```
$ mkdir config
$ docker run --rm -it -v $(pwd)/config:/etc/rclone l4t3b0/rclone
```

### Perform sync in a daily basis

A few environment variables allow you to customize the behavior of rclone:

* `ENV RCLONE_EXEC` set the binary executable file location. Defaults to `/usr/bin/rclone`
* `RCLONE_SRC` source location for `rclone sync/copy/move` command.
* `RCLONE_DST` destination location for `rclone sync/copy/move` command. Defaults to `/data`
* `RCLONE_CMD` set variable to `sync` `copy` or `move`  when running rclone. Defaults to `sync`
* `RCLONE_CMD_OPTS` additional options for `rclone sync/copy/move` command. Defaults to ``* `RCLONE_CONFIG_DIR` set the directory of the configuration file. Defaults to `/etc/rclone`
* `RCLONE_CONFIG_FILE` set the location of the configuration file. Defaults to `${RCLONE_CONFIG_DIR}/rclone.conf`
* `RCLONE_LOG_DIR` set the directory of the logging directory. Defaults to `/var/log/rclone`
* `RCLONE_LOG_LEVEL` set the logging level of the command rclone. Possible values are: `DEBUG/INFO/NOTICE/ERROR`. Defaults to `INFO`
* `RCLONE_LOG_ROTATE` if log files are older than the number of days defined by this variable, those will be deleted automatically. Defaults to `30`
* `RCLONE_PID_DIR` set the directory of the PID file. Defaults to `/var/run/rclone`
* `RCLONE_PID_FILE` set the location of the PID file. Defaults to `${RCLONE_PID_DIR}/rclone.pid`
* `CRON_EXPR` crontab schedule `0 0 * * *` to perform sync every midnight. Also supprorts cron shortcuts: `@yearly` `@monthly` `@weekly` `@daily` `@hourly`. Defaults to `@weekly`
* `CRON_ABORT_EXPR` crontab schedule `0 6 * * *` to abort sync at 6am
* `SYNC_ON_STARTUP` if the environment variable is set and the value is not an empty string, than rclone will be executed upon boot. Defaults to ``
* `HEALTHCHECKS_IO_URL` [healthchecks.io](https://healthchecks.io) url or similar cron monitoring to perform a `GET` after a successful sync
* `TZ` set the [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to use for the cron and log `America/Chicago`
* `PUID` set variable to specify user to run rclone as. Must also use GID.
* `PGID` set variable to specify group to run rclone as. Must also use UID.

**When using PUID/PGID the config and/or logs directory must be writeable by this UID**

```bash
$ docker run --rm -it -v $(pwd)/config:/etc/rclone -v /path/to/destination:/data -e RCLONE_SRC="onedrive:/" -e RCLONE_DST="/data" -e TZ="Europe/Budapest" -e CRON_EXPR="@daily" -e SYNC_ON_STARTUP=1 -e HEALTHCHECKS_IO_URL=https://hchk.io/hchk_uuid l4t3b0/rclone
```

See [rclone sync docs](https://rclone.org/commands/rclone_sync/) for source/dest syntax and additional options.

<br />
Credit to Brian J. Cardiff for the orginal project @ https://github.com/bcardiff/docker-rclone
<br />
Credit to pfidr for the orginal project @ https://github.com/pfidr/docker-rclone
