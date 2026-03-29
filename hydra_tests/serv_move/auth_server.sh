#!/bin/bash
# HTTP Basic Auth server for macOS

echo "=== MAC HTTP AUTH SERVER ==="
echo "Starting on port 8080"
echo "Login: admin"
echo "Password: secret123"
echo "Test with:"
echo "  curl -H 'Authorization: Basic YWRtaW46c2VjcmV0MTIz' http://localhost:8080"
echo "Press Ctrl+C to stop"
echo ""

# Correct credentials
CORRECT_USER="admin"
CORRECT_PASS="secret123"
CORRECT_TOKEN="YWRtaW46c2VjcmV0MTIz"  # admin:secret123 in base64

# HTML responses
SUCCESS_HTML="<html><body><h1>ACCESS GRANTED</h1><p>Welcome $CORRECT_USER!</p></body></html>"
FAIL_HTML="<html><body><h1>ACCESS DENIED</h1><p>Invalid credentials</p></body></html>"
AUTH_HTML="<html><body><h1>AUTH REQUIRED</h1><p>Please login</p></body></html>"

echo "Server listening on port 8080..."
echo "--------------------------------"

# Main server loop for macOS
while true; do
    # macOS netcat needs different syntax
    {
        # Read request line
        read -r REQUEST
        TIMESTAMP=$(date '+%H:%M:%S')
        echo "[$TIMESTAMP] Request: $REQUEST"
        
        # Read headers
        AUTH_HEADER=""
        CONTENT_LENGTH=0
        
        while read -r HEADER; do
            # Empty line ends headers
            if [[ -z "$HEADER" || "$HEADER" = $'\r' ]]; then
                break
            fi
            
            # Check for Authorization
            if [[ "$HEADER" =~ ^Authorization:[[:space:]]*(.*)$ ]]; then
                AUTH_HEADER="${BASH_REMATCH[1]}"
                echo "  Auth header found"
            fi
        done
        
        # Process request
        if [[ -n "$AUTH_HEADER" ]]; then
            if [[ "$AUTH_HEADER" == *"$CORRECT_TOKEN"* ]]; then
                # Send success response
                echo "HTTP/1.1 200 OK"
                echo "Content-Type: text/html"
                echo "Content-Length: ${#SUCCESS_HTML}"
                echo ""
                echo "$SUCCESS_HTML"
                echo "  >> Access granted to $CORRECT_USER"
            else
                # Send fail response
                echo "HTTP/1.1 401 Unauthorized"
                echo "WWW-Authenticate: Basic realm=\"Restricted Area\""
                echo "Content-Type: text/html"
                echo "Content-Length: ${#FAIL_HTML}"
                echo ""
                echo "$FAIL_HTML"
                echo "  >> Invalid credentials"
            fi
        else
            # Send auth required response
            echo "HTTP/1.1 401 Unauthorized"
            echo "WWW-Authenticate: Basic realm=\"Restricted Area\""
            echo "Content-Type: text/html"
            echo "Content-Length: ${#AUTH_HTML}"
            echo ""
            echo "$AUTH_HTML"
            echo "  >> No credentials provided"
        fi
        
        # Small delay to ensure response is sent
        sleep 0.1
    } | nc -l 8080 2>/dev/null
    
    # Check if nc failed
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start server. Port 8080 may be in use."
        echo "Trying port 8081..."
        sleep 2
    fi
done