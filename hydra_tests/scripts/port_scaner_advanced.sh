#!/bin/bash

HOST="${1:-localhost}"
START="${2:-1}"
END="${3:-100}"
LOG_FILE="$scan_$(date +%s).log"

echo "scan $HOST ports $START-$END" | tee "$LOG_FILE"
echo "starting at $(date)" | tee -a "$LOG_FILE"

open_count=0
closed_count=0

for port in $(seq $START $END); do
	if timeout 1 bash -c "echo >/dev/tcp/$HOST/$port" 2>/dev/null; then
		echo "port $port : OPEN" | tee -a "$LOG_FILE"
		((open_count++))
	else
		echo "port $port scan failed" >> "${LOG_FILE}"
		((closed_count++))
	fi
done 2> "${LOG_FILE}.errors"

echo "------------------------" | tee -a "${LOG_FILE}"
echo "open : $open_count, closed : $closed_count" | tee -a "${LOG_FILE}"
echo "main log : $LOG_FILE" | tee -a "${LOG_FILE}"
echo "errors log : ${LOG_FILE},errors" | tee -a "${LOG_FILE}"

if [[ -s "${LOG_FILE}.errors" ]]; then
	echo -e "last 5 errors : "
	echo -5 "${LOG_FILE}.errors"
fi
