#!/bin/bash
set -euo pipefail

echo "===== Backup started ====="

SOURCE_DIR=$1
FINAL_DIR=$2

./backup.sh "$SOURCE_DIR" "$FINAL_DIR"

ARCHIVE=$(ls -t "$FINAL_DIR"/*.tar.gz | head -1)
./verify.sh "$ARCHIVE"

echo "====Backup successful====="
