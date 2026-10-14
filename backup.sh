#!/bin/bash
set -e
echo "========================="

SOURCE_DIR=$1
FINAL_DIR=$2
DATE=$(date +%Y-%m-%d-%H%M%S) 

if [ -z "$SOURCE_DIR" ]; then
    echo "Usage: ./backup.sh SOURCE_DIR FINAL_DIR"
    exit 1
fi

if [ -z "$FINAL_DIR" ]; then
    echo "Usage: ./backup.sh SOURCE_DIR FINAL_DIR"
    exit 1
fi

if ! ./precheck.sh; then
    echo "Archiving tools not installed"
    exit 1
fi

mkdir -p $FINAL_DIR
ARCHIVE="$FINAL_DIR/backup-$DATE.tar.gz"
tar -czf "$ARCHIVE" "$SOURCE_DIR"

echo "Backup created: $ARCHIVE"
du -h "$ARCHIVE"
