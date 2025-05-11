#!/bin/bash

# Function to encrypt text
encrypt() {
    local text="$1"
    local shift="$2"
    local result=""
    for ((i = 0; i < ${#text}; i++)); do
        char="${text:i:1}"
        if [[ "$char" =~ [A-Z] ]]; then
            # Uppercase letters
            result+=$(printf "\\$(printf '%03o' $(( ( $(printf '%d' "'$char") - 65 + shift ) % 26 + 65 )))")
        elif [[ "$char" =~ [a-z] ]]; then
            # Lowercase letters
            result+=$(printf "\\$(printf '%03o' $(( ( $(printf '%d' "'$char") - 97 + shift ) % 26 + 97 )))")
        else
            # Non-alphabetic characters (unchanged)
            result+="$char"
        fi
    done
    echo "$result"
}

# Function to decrypt text
decrypt() {
    local text="$1"
    local shift="$2"
    local result=""
    for ((i = 0; i < ${#text}; i++)); do
        char="${text:i:1}"
        if [[ "$char" =~ [A-Z] ]]; then
            # Uppercase letters
            result+=$(printf "\\$(printf '%03o' $(( ( $(printf '%d' "'$char") - 65 - shift + 26 ) % 26 + 65 )))")
        elif [[ "$char" =~ [a-z] ]]; then
            # Lowercase letters
            result+=$(printf "\\$(printf '%03o' $(( ( $(printf '%d' "'$char") - 97 - shift + 26 ) % 26 + 97 )))")
        else
            # Non-alphabetic characters (unchanged)
            result+="$char"
        fi
    done
    echo "$result"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    -s)
        input_string="$2"
        shift 2
        ;;
    -k)
        shift_value="$2"
        shift 2
        ;;
    -if)
        input_file="$2"
        shift 2
        ;;
    -of)
        output_file="$2"
        shift 2
        ;;
    -d)
        mode="decrypt"
        shift
        ;;
    *)
        echo "Invalid option: $1"
        exit 1
        ;;
    esac
done

# Validate shift value
if [[ -z "$shift_value" || ! "$shift_value" =~ ^[0-9]+$ ]]; then
    echo "Error: Shift value (-k) must be a positive integer."
    exit 1
fi

# Perform encryption or decryption
if [[ -n "$input_string" ]]; then
    if [[ "$mode" == "decrypt" ]]; then
        result=$(decrypt "$input_string" "$shift_value")
    else
        result=$(encrypt "$input_string" "$shift_value")
    fi
    echo "$result"
elif [[ -n "$input_file" ]]; then
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file not found."
        exit 1
    fi
    input_content=$(cat "$input_file")
    if [[ "$mode" == "decrypt" ]]; then
        result=$(decrypt "$input_content" "$shift_value")
    else
        result=$(encrypt "$input_content" "$shift_value")
    fi
    if [[ -n "$output_file" ]]; then
        echo "$result" >"$output_file"
    else
        echo "$result"
    fi
else
    echo "Error: No input provided. Use -s for string input or -if for file input."
    exit 1
fi

