# 7DaysToDie-DedicatedServer

Scripts and wrappers to help with managing and running a 7 Days dedicated server

## Assumed folder structure

```
base_folder
|
-> scripts: All of these scripts
-> data: Persistent data used by the server, worlds, saves, and server_config.xml
-> server_install: The directory that the Steam app is installed to
```

The folder structure is assumed by the scripts, since it's intended that you can run these in a Docker container, and if you want to have more worlds, saves, server configs, etc... you can run multiple containers with different host directories mounted into standardized expected target directories.

## Dependencies

- `screen` used to background the server process, and if you want to run the time dilation script.
- `steamcmd` for automatic updates, it's expected this is in the path.

## `serverconfig.xml`

- Goes in your `data` directory
- Configure it like normal.

## `start_wrapper.sh`

This is the entrypoint, pass in the filename of your serverconfig.xml in the data director as the first argument.

This will call the `update_server.sh` script (unfortunately the wrapper hardcodes the beta target), to make sure it's up to date on reboot. And then it starts the server.

## `update_dedicated.sh`

Just calls the steamcmd `appupdate` function to update the server install

## `startserver.sh`

A fork of the provided `startserver.sh`, but that runs it in screen to background it.

## `backup.sh`

A script that you can use in a cron job that assumes that all folders are on ZFS, and will:

- Issue an `sa` save comment over the telnet port for the dedicated server to save all chunks.
- Compress and tar up the current version of the world and saves and send it via rclone to a remote (hardcoded to be called `od`, so change this).
- Generate a `zfs send` including all incrementals and snapshots of the save directories, compress it, and send it to the rclone remote.


This is useful for keeping historical deltas, and the ability to revert, as well as making the world sharable.

## `time_dilation.sh`

This script varies the `TimeOfDayIncPerSec` tick rate of the in-game clock based on the number of currently logged in players. It has a configurable "Normal time progression when X players are logged in", and it will also stop time when only one player is logged in. It connects to the telnet port on localhost, and runs in the foreground, so you'll need to work with that (`screen` is a good chocie).
