#!/bin/bash
set -e
set -u
echo "....Verifying backup toolkit..."

TOOLS="tar gzip"
MISSING=0

for tool in $TOOLS; do
    if command -v "$tool" &>/dev/null; then
        echo "$tool is installed"
    else
        echo "$tool not installed, install first"
        MISSING=1
    fi
done

if [ "$MISSING" -eq 1 ]; then
    echo "some required tools are missing"
    exit 1
fi

echo "All required tools are installed"
