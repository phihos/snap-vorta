#!/bin/sh

ls /var/lib/snapd/hostfs >/dev/null 2>&1
retval_hostfs=$?
ls "$SNAP_REAL_HOME" >/dev/null 2>&1
retval_home=$?

if [ $retval_hostfs -eq 0 ]; then
  echo "Snap plug system-backup connected. Setting HOME to /var/lib/snapd/hostfs$SNAP_REAL_HOME..."
  export HOME=/var/lib/snapd/hostfs"$SNAP_REAL_HOME"
elif [ $retval_home -eq 0 ]; then
  echo "Snap plug home connected. Setting HOME to $SNAP_REAL_HOME..."
  export HOME="$SNAP_REAL_HOME"
else
  echo "Neither home nor system-backup plugs connected."
  echo "Run either "
  echo "  * \"snap connect $SNAP_NAME:home\" for personal backups or"
  echo "  * \"snap connect $SNAP_NAME:system-backup\" for fully system backups"
fi

exec "${@}"
