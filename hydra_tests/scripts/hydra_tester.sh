#!/bin/bash

TARGET="localhost"
PROTOCOL="ssh"
PORT="22"
THREADS=4
TIMEOUT=30

echo "hydra password tstr"
echo "trgt : $TARGET"
echo "prtcl : $PROTOCOL"
echo "port : $PORT"
echo "threads : $THREADS"
echo "timeout : ${TIMEOUT}"
echo ""

if ! command -v hydra &> /dev/null; then
	echo "error : hydra nt instl"
	exit 1
fi

if [ ! -f "users.txt" ]; then
	echo "creating sample users.txt..."
	cat > users.txt << EOF
admin
root
user
EOF
fi

if [ ! -f "password.txt" ]; then
	echo "creating smpl password.txt..."
	cat > password.txt << EOF
password
123456
admin
test
EOF
fi

echo "starting hydra attk..."
echo "$(date)"
echo ""

hydra -I -V -f \
	-L users.txt \
	-P password.txt \
	-t $THREADS \
	-W $TIMEOUT \
	$PROTOCOL://$TARGET:$PORT 2>&1 | tee hydra_attack.log

echo ""
echo "end time $(date)"
echo "results saved"

if grep -q "login: hydra_attack.log"; then
	echo ""
	echo "found credentials:"
	grep "login:" hydra_attack.log
else
	echo ""
	echo "no credentials found."
fi
