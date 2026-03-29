#!/bin/bash

LOG_DIR="attack_logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/attack_$TIMESTAMP.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "Attack started: $(date)"
echo "Target: $1"
echo "Wordlist: $2"
echo ""

# attack code
./brute_http_basic_fixed.sh

echo ""
echo "Attack finished: $(date)"
echo "Log saved: $LOG_FILE"
