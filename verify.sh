#!/bin/bash
set -e
 echo "========================="

ARCHIVE_PATH="$1"

if [ -z "$ARCHIVE_PATH" ]; then
    echo "Usage: ./verify.sh <ARCHIVE_PATH>"
    exit 1
fi

if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "Archive not found: $ARCHIVE_PATH"
    exit 1
fi


if ! tar -tzf "$ARCHIVE_PATH" > /dev/null 2>&1; then
    echo "Archive is corrupt or unreadable: $ARCHIVE_PATH"
    exit 1
fi

COUNT=$(tar -tzf "$ARCHIVE_PATH" | wc -l )
echo "Archive is ok: $ARCHIVE_PATH contains $COUNT file(s)"

