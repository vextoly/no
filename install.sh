#!/bin/sh

INSTALL_DIR="/usr/local/bin"
TARGET="${INSTALL_DIR}/no"

clear
echo "=== no v1.2 installer by ihatemustard ==="
echo
echo "1) Install no"
echo "2) Remove no"
echo "3) Cancel"
echo
printf "Select an option [1-3]: "
read choice

need_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: must be run as root (use su, sudo, or doas)"
        exit 1
    fi
}

case "$choice" in
    1)
        need_root
        echo "Installing 'no' v1.2..."
        mkdir -p "$INSTALL_DIR"

        cat > "$TARGET" << 'EOF'
#!/bin/sh

VERSION="1.2"

TEXT="n"
INTERVAL=0
TIMES=0
USE_RANDOM=0
RANDOM_ITEMS=""
USE_COUNT=0
OUTPUT=""
COMMAND=""

# v1.2 Sequence Variables
SEQ_ACTIVE=0
SEQ_START=""
SEQ_END=""
STEP=1
PAD=0
PRECISION=-1

usage() {
    echo "Usage: no [text] [options]"
    echo
    echo "Options:"
    echo "  -i, --interval <seconds>   Add a delay between outputs"
    echo "  -v, --version              Show version info"
    echo "  -h, --help                 Show this help"
    echo "  -r, --random <list>        Repeat random strings from comma-separated list"
    echo "  -c, --count                Prepend counter to each output"
    echo "  -o, --output <file>        Write output to a file instead of stdout"
    echo "  -t, --times <n>            Number of times to repeat (0 = infinite)"
    echo "  -cmd, --command <cmd>      Execute a shell command repeatedly"
    echo "  --seq <start:end>          Generate a sequence (e.g., 1:5 or a:z)"
    echo "  --step <n>                 Increment for sequence (default: 1)"
    echo "  --pad <n>                  Zero-pad numbers (e.g., --pad 3 -> 001)"
    echo "  --precision <n>            Decimal places for numbers"
    echo
    echo "Examples:"
    echo "  no"
    echo "  no example -o file.txt"
    echo "  no --interval 0.5 --times 5"
    echo "  no --random \"no,nah,nop\" --times 4"
    echo "  no --count --times 3"
    echo "  no --command \"date\" --times 3 --interval 1"
    echo "  no --seq 1:5 --pad 3"
    echo "  no --seq a:e"
    echo "  no --seq 1:2 --step 0.5 --precision 2"
    exit 0
}

pick_random() {
    LIST="$1"
    COUNT=$(echo "$LIST" | awk -F',' '{print NF}')
    RAND_BYTE=$(od -An -N2 -tu2 /dev/urandom | tr -d ' ')
    INDEX=$(( (RAND_BYTE % COUNT) + 1 ))
    echo "$LIST" | awk -v i="$INDEX" -F',' '{print $i}'
}

# Argument Parsing
while [ "$#" -gt 0 ]; do
    case "$1" in
        -i|--interval) INTERVAL="$2"; shift 2 ;;
        -v|--version) echo "no v$VERSION"; exit 0 ;;
        -h|--help) usage ;;
        -r|--random) USE_RANDOM=1; RANDOM_ITEMS="$2"; shift 2 ;;
        -c|--count) USE_COUNT=1; shift ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        -t|--times) TIMES="$2"; shift 2 ;;
        -cmd|--command) COMMAND="$2"; shift 2 ;;
        --seq)
            SEQ_ACTIVE=1
            SEQ_START=$(echo "$2" | cut -d':' -f1)
            SEQ_END=$(echo "$2" | cut -d':' -f2)
            shift 2
            ;;
        --step) STEP="$2"; shift 2 ;;
        --pad) PAD="$2"; shift 2 ;;
        --precision|--prec) PRECISION="$2"; shift 2 ;;
        *) TEXT="$1"; shift ;;
    esac
done

# Sequence Logic Setup
IS_CHAR_SEQ=0
if [ "$SEQ_ACTIVE" -eq 1 ]; then
    if echo "$SEQ_START" | grep -Eq '^[a-zA-Z]$'; then
        IS_CHAR_SEQ=1
        CURRENT_ASC=$(printf '%d' "'$SEQ_START")
        END_ASC=$(printf '%d' "'$SEQ_END")
        [ "$TIMES" -eq 0 ] && TIMES=$(awk -v s="$CURRENT_ASC" -v e="$END_ASC" -v st="$STEP" 'BEGIN { printf "%d", (e - s) / st + 1 }')
    else
        CURRENT="$SEQ_START"
        [ "$TIMES" -eq 0 ] && TIMES=$(awk -v s="$SEQ_START" -v e="$SEQ_END" -v st="$STEP" 'BEGIN { printf "%d", (e - s) / st + 1 }')
    fi
fi

i=0
while [ "$TIMES" -eq 0 ] || [ "$i" -lt "$TIMES" ]; do
    if [ -n "$COMMAND" ]; then
        OUT=$(sh -c "$COMMAND")
    elif [ "$USE_RANDOM" -eq 1 ] && [ -n "$RANDOM_ITEMS" ]; then
        OUT=$(pick_random "$RANDOM_ITEMS")
    elif [ "$SEQ_ACTIVE" -eq 1 ]; then
        if [ "$IS_CHAR_SEQ" -eq 1 ]; then
            OUT=$(printf "\\$(printf '%03o' "$CURRENT_ASC")")
            CURRENT_ASC=$(awk -v c="$CURRENT_ASC" -v s="$STEP" 'BEGIN { print c + s }')
        else
            OUT="$CURRENT"
            CURRENT=$(awk -v c="$CURRENT" -v s="$STEP" 'BEGIN { print c + s }')
        fi
    else
        OUT="$TEXT"
    fi

    # Formatting Engine
    if [ "$IS_CHAR_SEQ" -eq 0 ] && echo "$OUT" | grep -Eq '^[+-]?[0-9]*\.?[0-9]+$'; then
        FINAL_OUT=$(awk -v n="$OUT" -v p="$PRECISION" -v w="$PAD" 'BEGIN {
            if (p >= 0) {
                fmt = (w > 0) ? "%0" w "." p "f" : "%." p "f";
            } else {
                fmt = (w > 0) ? "%0" w "g" : "%g";
                if (n !~ /\./ && w > 0) fmt = "%0" w "d";
            }
            printf fmt, n
        }')
    else
        FINAL_OUT="$OUT"
    fi

    PREFIX=""
    [ "$USE_COUNT" -eq 1 ] && PREFIX="$((i+1)): "

    if [ -n "$OUTPUT" ]; then
        echo "${PREFIX}${FINAL_OUT}" >> "$OUTPUT"
    else
        echo "${PREFIX}${FINAL_OUT}"
    fi

    i=$((i+1))
    if [ "$(awk -v i="$INTERVAL" 'BEGIN { print (i > 0) }')" -eq 1 ]; then
        sleep "$INTERVAL"
    fi
done
EOF

        chmod 0755 "$TARGET"
        echo "Installed: $TARGET"
        echo "Test with: no --seq 1:3 --pad 2"
        ;;
    2)
        need_root
        if [ -f "$TARGET" ]; then
            rm "$TARGET"
            echo "Removed: $TARGET"
        else
            echo "'no' is not installed."
        fi
        ;;
    3)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac
