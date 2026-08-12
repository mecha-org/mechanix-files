#!/bin/sh
APPDIR="/usr/share/mechanix/mechanix-files"
exec "$APPDIR/mechanix_files" --bundle="$APPDIR" "$@"
