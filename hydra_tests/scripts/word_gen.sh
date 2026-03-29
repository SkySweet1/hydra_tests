#!/bin/bash

PREFIX="admin"
SUFFIX="123"
YEARS="2020 2021 2022 2023 2024 2025"

echo "Generating wordlist..."
{
    # Common passwords
    echo "password"
    echo "123456"
    echo "admin"
    echo "qwerty"
    
    # Combinations
    for year in $YEARS; do
        echo "${PREFIX}${year}"
        echo "${PREFIX}${SUFFIX}"
        echo "${year}${SUFFIX}"
    done
    
    # RockYou style
    for i in {1..100}; do
        echo "password$i"
        echo "admin$i"
    done
} > custom_wordlist.txt

echo "Generated $(wc -l < custom_wordlist.txt) passwords"
