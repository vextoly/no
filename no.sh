#!/bin/sh

VERSION="1.4"

usage() {
    cat << EOF
Usage: no [text] [options]
Options:
  -i, --interval <sec>     Add a delay
  -v, --version            Show version
  -h, --help               Show help
  -r, --random <list>      Truly random selection
  -c, --count              Prepend counter
  -o, --output <file>      Write to file
  -t, --times <n>          Number of repeats
  -f, --format <str>       Printf-style format
  -s, --separator <str>    Custom separator
  -cols <n>                N columns
  --seq <start:end>        Integer sequence
  --step <n>               Increment
  --pad <n>                Zero-pad
EOF
    exit 0
}

# Defaults
TEXT="n"
INTERVAL=0
TIMES=0
USE_RANDOM=0
USE_COUNT=0
SEPARATOR="\n"
COLUMNS=1
SEQ_ACTIVE=0
PAD=0
STEP=1

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help) usage ;;
        -v|--version) echo "no $VERSION"; exit 0 ;;
        -i|--interval) INTERVAL="$2"; shift 2 ;;
        -r|--random) USE_RANDOM=1; RANDOM_ITEMS=$(echo "$2" | tr ',' ' '); shift 2 ;;
        -c|--count) USE_COUNT=1; shift ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        -t|--times) TIMES="$2"; shift 2 ;;
        -f|--format) FORMAT="$2"; shift 2 ;;
        -s|--separator) SEPARATOR="$2"; shift 2 ;;
        -cols) COLUMNS="$2"; shift 2 ;;
        --seq)
            SEQ_ACTIVE=1
            SEQ_START=$(echo "$2" | cut -d':' -f1)
            SEQ_END=$(echo "$2" | cut -d':' -f2)
            shift 2 ;;
        --step) STEP="$2"; shift 2 ;;
        --pad) PAD="$2"; shift 2 ;;
        *) TEXT="$1"; shift ;;
    esac
done

[ -n "$OUTPUT" ] && exec > "$OUTPUT"

if [ "$SEQ_ACTIVE" -eq 1 ]; then
    [ "$SEQ_START" -gt "$SEQ_END" ] && [ "$STEP" -gt 0 ] && STEP=$(( -STEP ))
    if [ "$TIMES" -eq 0 ]; then
        DIFF=$(( SEQ_END - SEQ_START ))
        [ $DIFF -lt 0 ] && ABS_DIFF=$(( -DIFF )) || ABS_DIFF=$DIFF
        [ $STEP -lt 0 ] && ABS_STEP=$(( -STEP )) || ABS_STEP=$STEP
        TIMES=$(( (ABS_DIFF / ABS_STEP) + 1 ))
    fi
fi

# Pre-seed for random using date
SEED=$(date +%S)

i=0
while [ "$TIMES" -eq 0 ] || [ "$i" -lt "$TIMES" ]; do
    # 1. Logic
    if [ "$SEQ_ACTIVE" -eq 1 ]; then
        OUT=$((SEQ_START + (i * STEP)))
    elif [ "$USE_RANDOM" -eq 1 ]; then
        set -- $RANDOM_ITEMS
        SEED=$(( (SEED * 1103515245 + 12345) & 2147483647 ))
        IDX=$(( (SEED % $#) + 1 ))
        eval OUT=\${$IDX}
    else
        OUT="$TEXT"
    fi

    # 2. Counter
    [ "$USE_COUNT" -eq 1 ] && printf "%d: " "$((i+1))"

    # 3. Formatting & Output (Fixed Format + Pad logic)
    # If padding is set, we prepare the value first
    VAL="$OUT"
    if [ "$PAD" -gt 0 ]; then
        VAL=$(printf "%0${PAD}d" "$OUT")
    fi

    if [ -n "$FORMAT" ]; then
        printf "$FORMAT" "$VAL"
    else
        printf "%s" "$VAL"
    fi

    # 4. Separator
    if [ "$COLUMNS" -gt 1 ]; then
        if [ "$(( (i+1) % COLUMNS ))" -eq 0 ]; then
            printf "\n"
        else
            printf "\t"
        fi
    else
        printf "%b" "$SEPARATOR"
    fi

    i=$((i+1))
    [ "$INTERVAL" != "0" ] && sleep "$INTERVAL"
done
[ "$COLUMNS" -gt 1 ] && [ "$(( i % COLUMNS ))" -ne 0 ] && printf "\n"
