#!/bin/sh

export LC_ALL=C

VERSION="1.4-fix2"

OLD_STTY=$(stty -g)

cleanup() {
    stty "$OLD_STTY"
    exit 130
}

trap cleanup INT TERM EXIT

stty intr ^E

TEXT="n"
INTERVAL=0
TIMES=0
USE_RANDOM=0
RANDOM_ITEMS=""
USE_COUNT=0
OUTPUT=""
SEPARATOR="\n"
COLUMNS=1
FORMAT=""
SEQ_ACTIVE=0
SEQ_START=""
SEQ_END=""
STEP=""
PAD=0
PRECISION=-1
PREFIX_STR=""
SUFFIX_STR=""
WIDTH=0
CYCLE=0
SKIP=0
COMMAND_STR=""

usage() {
    cat <<EOF
Usage: no [text] [options]

Core Options:
  -t, --times <n>      Stop after N outputs (0=infinite)
  -i, --interval <sec> Sleep between outputs
  -o, --output <file>  Write to file
  -r, --random <list>  Pick random item from comma-sep list
  -cmd, --command <q>  Execute shell command (captures all output)
  -v, --version        Show version

Kill Switch:
  CTRL + E             Instantly kills the process and returns to shell.

Formatting:
  -f, --format <str>    Printf-style format (e.g., "ID-%s")
  -s, --separator <str> Character(s) between items (default: \n)
  -cols <n>             Output in N columns (uses tabs)
  -c, --count           Prepend line counter (1: , 2: , etc.)
  --prefix <str>        Add string before each output
  --suffix <str>        Add string after each output
  --width <n>           Right-align output to fixed width

Sequences:
  --seq <start:end>     Generate sequence (1:100, a:z, -5:5)
  --step <n>            Sequence increment size
  --cycle               Repeat sequence infinitely (requires -t)
  --skip <n>            Skip first N items of sequence
  --pad <n>             Zero-pad numbers (e.g., 001, 002)
  --precision <n>       Decimal places for floats
  --verify              Run internal self-tests
EOF
    exit 0
}

verify_script() {
    printf -- "Starting verification suite for v$VERSION...\n"
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
    case "$0" in /*|./*) script_path="$0" ;; *) script_path="./$0" ;; esac

    FAILED_TESTS=0
    TOTAL_TESTS=0

    test_case() {
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        NAME="$1"; CMD="$2"; EXPECTED=$(printf -- "$3")
        RESULT=$(eval "$script_path $CMD" 2>/dev/null)

        if [ "$RESULT" = "$EXPECTED" ]; then
            printf -- "${GREEN}[PASS]${NC} %s\n" "$NAME"
        else
            printf -- "${RED}[FAIL]${NC} %s\n" "$NAME"
            printf -- "    Expected: [%s]\n" "$3"
            printf -- "    Got:      [%s]\n" "$RESULT"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    }

    test_case "Basic Repetition" "-t 2 'hi'" "hi\nhi\n"
    test_case "Numeric Sequence" "--seq 1:3" "1\n2\n3\n"
    test_case "Reverse Numeric" "--seq 3:1" "3\n2\n1\n"
    test_case "Character Sequence" "--seq a:c" "a\nb\nc\n"
    test_case "Prefix/Suffix" "-t 1 'x' --prefix 'A' --suffix 'B'" "AxB\n"
    test_case "Cycle Sequence" "--seq 1:2 --cycle -t 4" "1\n2\n1\n2\n"
    test_case "Skip Logic" "--seq 1:5 --skip 3" "4\n5\n"
    test_case "Zero Padding" "--seq 9:11 --pad 3" "009\n010\n011\n"
    test_case "Precision Floats" "--seq 1:1.5 --step 0.5 --prec 1" "1.0\n1.5\n"
    test_case "Column Layout" "--seq 1:4 -cols 2" "1\t2\n3\t4\n"
    test_case "Format String" "-t 1 -f 'Value is %s' 'test'" "Value is test\n"
    test_case "Negative Sequence" "--seq -1:-3" "-1\n-2\n-3\n"
    test_case "Cross Zero Seq" "--seq -1:1" "-1\n0\n1\n"
    test_case "Large Step" "--seq 1:10 --step 5" "1\n6\n"
    test_case "Step larger than range" "--seq 1:2 --step 5" "1\n"
    test_case "Float Sequence Start" "--seq 0.5:1.5 --step 0.5" "0.5\n1\n1.5\n"
    test_case "Reverse Float Seq" "--seq 1.0:0.0 --step -0.5" "1\n0.5\n0\n"
    test_case "Char Seq Reverse" "--seq c:a" "c\nb\na\n"
    test_case "Char Seq Uppercase" "--seq X:Z" "X\nY\nZ\n"
    test_case "Fixed Width Align" "-t 1 'hi' --width 5" "   hi\n"
    test_case "Width with Prefix" "-t 1 'x' --prefix '>' --width 3" " >x\n"
    test_case "Padding on single num" "-t 1 '7' --pad 2" "07\n"
    test_case "Hex Format" "-t 1 '255' -f '%x'" "ff\n"
    test_case "Scientific Format" "-t 1 '1000' -f '%e'" "1.000000e+03\n"
    test_case "Precision Rounding" "-t 1 '1.555' --prec 2" "1.56\n"
    test_case "Format with literal %" "-t 1 '5' -f '%% %s %%'" "%% 5 %%"
    test_case "Empty string width" "-t 1 '' --width 3" "   \n"
    test_case "Custom Separator" "-t 2 'ok' -s ','" "ok,ok,"
    test_case "Space Separator" "-t 2 'x' -s ' '" "x x "
    test_case "Cols with 3 items" "--seq 1:3 -cols 3" "1\t2\t3\n"
    test_case "Cols uneven" "--seq 1:5 -cols 2" "1\t2\n3\t4\n5\n"
    test_case "Cols with cycle" "--seq 1:2 --cycle -t 4 -cols 2" "1\t2\n1\t2\n"
    test_case "Tab Separator Literal" "-t 2 'a' -s '\t'" "a\ta"
    test_case "Newline Separator" "-t 2 'a' -s '\n'" "a\na\n"
    test_case "Cols with custom prefix" "--seq 1:2 --prefix '#' -cols 2" "#1\t#2\n"
    test_case "Counter check" "-t 2 'hi' -c" "1: hi\n2: hi\n"
    test_case "Counter with Sequence" "--seq 10:11 -c" "1: 10\n2: 11\n"
    test_case "Prefix and Suffix" "-t 1 'mid' --prefix '[' --suffix ']'" "[mid]\n"
    test_case "Multi-char prefix" "-t 1 'x' --prefix 'START_'" "START_x\n"
    test_case "Counter with Prefix" "-t 1 'x' -c --prefix 'PRE'" "1: PREx\n"
    test_case "Suffix only" "-t 1 'x' --suffix '...'" "x...\n"
    test_case "Skip all items" "--seq 1:3 --skip 5" ""
    test_case "Skip exactly all" "--seq 1:3 --skip 3" ""
    test_case "Cycle and Skip" "--seq 1:3 --cycle --skip 1 -t 3" "2\n3\n1\n"
    test_case "Cycle non-sequence" "-t 4 'hi' --cycle" "hi\nhi\nhi\nhi\n"
    test_case "Skip on non-sequence" "-t 5 'a' --skip 2" "a\na\na\n"
    test_case "Negative step sequence" "--seq 10:0 --step -5" "10\n5\n0\n"
    test_case "Format + Padding" "--seq 1:1 --pad 3 -f 'ID-%s'" "ID-001\n"
    test_case "Cols + Width" "--seq 1:2 -cols 2 --width 3" "  1\t  2\n"
    test_case "Random from 1 item" "-r 'only' -t 1" "only\n"
    test_case "Command flag" "-cmd 'echo t' -t 1" "t"

    printf -- "----------------------------------------------\n"
    [ $FAILED_TESTS -eq 0 ] && printf "${GREEN}SUCCESS: All tests passed.${NC}\n" || printf "${RED}FAILURE: $FAILED_TESTS tests failed.${NC}\n"
    exit $FAILED_TESTS
}

# Helper: Ensure flags have required arguments
# Allows negative numbers (integers/floats) but rejects flags starting with -
check_arg() {
    if [ -z "$2" ]; then
        echo "Error: Argument for $1 is missing."
        exit 1
    fi
    # Check if argument starts with '-' but is NOT a number (e.g. another flag)
    case "$2" in
        -[0-9]*) ;; # Allow negative numbers
        -*) echo "Error: Argument for $1 cannot be a flag ($2)."; exit 1 ;;
    esac
}

while [ $# -gt 0 ]; do
    case "$1" in
        --verify)       verify_script ;;
        -v|--version)   echo "no v$VERSION"; exit 0 ;;
        -h|--help)      usage ;;
        -cmd|--command) check_arg "$1" "$2"; COMMAND_STR="$2"; shift ;;
        -r|--random)    check_arg "$1" "$2"; USE_RANDOM=1; RANDOM_ITEMS="$2"; shift ;;
        -c|--count)     USE_COUNT=1 ;;
        -o|--output)    check_arg "$1" "$2"; OUTPUT="$2"; shift ;;
        -t|--times)     check_arg "$1" "$2"; TIMES="$2"; shift ;;
        -f|--format)    check_arg "$1" "$2"; FORMAT="$2"; shift ;;
        -s|--separator) check_arg "$1" "$2"; SEPARATOR="$2"; shift ;;
        -cols)          check_arg "$1" "$2"; COLUMNS="$2"; shift ;;
        -i|--interval)  check_arg "$1" "$2"; INTERVAL="$2"; shift ;;
        --prefix)       check_arg "$1" "$2"; PREFIX_STR="$2"; shift ;;
        --suffix)       check_arg "$1" "$2"; SUFFIX_STR="$2"; shift ;;
        --width)        check_arg "$1" "$2"; WIDTH="$2"; shift ;;
        --cycle)        CYCLE=1 ;;
        --skip)         check_arg "$1" "$2"; SKIP="$2"; shift ;;
        --seq)          check_arg "$1" "$2"; SEQ_ACTIVE=1; SEQ_START="${2%%:*}"; SEQ_END="${2#*:}"; shift ;;
        --step)         check_arg "$1" "$2"; STEP="$2"; shift ;;
        --pad)          check_arg "$1" "$2"; PAD="$2"; shift ;;
        --precision|--prec) check_arg "$1" "$2"; PRECISION="$2"; shift ;;
        *)              TEXT="$1" ;;
    esac
    shift
done

IS_CHAR_SEQ=0; START_VAL=0; END_VAL=0; SEQ_LEN=0; SHOULD_EXIT=0
if [ "$SEQ_ACTIVE" -eq 1 ]; then
    case "$SEQ_START" in
        [a-zA-Z]) IS_CHAR_SEQ=1; START_VAL=$(printf -- '%d' "'$SEQ_START"); END_VAL=$(printf -- '%d' "'$SEQ_END") ;;
        *) START_VAL="$SEQ_START"; END_VAL="$SEQ_END" ;;
    esac
    [ -z "$STEP" ] && STEP=$(awk -v s="$START_VAL" -v e="$END_VAL" 'BEGIN {print (e >= s ? 1 : -1)}')
    SEQ_LEN=$(awk -v s="$START_VAL" -v e="$END_VAL" -v st="$STEP" 'BEGIN {
        diff = (e - s);
        if ((st > 0 && diff < 0) || (st < 0 && diff > 0)) { print 0; exit }
        count = int(diff / st) + 1;
        print (count < 0 ? 0 : count)
    }')
    if [ "$TIMES" -eq 0 ] && [ "$CYCLE" -eq 0 ]; then
        TIMES=$((SEQ_LEN - SKIP)); [ "$TIMES" -le 0 ] && SHOULD_EXIT=1
    fi
else
    if [ "$SKIP" -gt 0 ] && [ "$TIMES" -gt 0 ]; then
        TIMES=$((TIMES - SKIP)); [ "$TIMES" -le 0 ] && SHOULD_EXIT=1
    fi
fi

if [ "$SHOULD_EXIT" -eq 1 ]; then exit 0; fi

awk -v text="$TEXT" -v limit="$TIMES" -v use_rand="$USE_RANDOM" \
    -v r_list="$RANDOM_ITEMS" -v use_cnt="$USE_COUNT" -v cols="$COLUMNS" \
    -v sep="$SEPARATOR" -v fmt="$FORMAT" -v s_act="$SEQ_ACTIVE" \
    -v s_start="$START_VAL" -v s_step="$STEP" -v is_c="$IS_CHAR_SEQ" \
    -v pad="$PAD" -v prec="$PRECISION" -v interval="$INTERVAL" \
    -v pre="$PREFIX_STR" -v suf="$SUFFIX_STR" -v width="$WIDTH" \
    -v cycle="$CYCLE" -v skip="$SKIP" -v seq_len="$SEQ_LEN" \
    -v cmd_str="$COMMAND_STR" \
'BEGIN {
    if (sep == "\\n") sep = "\n"; if (sep == "\\t") sep = "\t";
    if (use_rand) { srand(); r_n = split(r_list, r_arr, ","); }

    do_num_fmt = (!is_c && (pad > 0 || prec >= 0));
    if (do_num_fmt) f_num = "%" (pad > 0 ? "0" pad : "") (prec >= 0 ? "." prec : "") (prec >= 0 ? "f" : "d");

    i = 0;
    while (limit == 0 || i < limit) {
        if (cmd_str != "") {
             val = "";
             # Loop through all lines of command output
             while ((cmd_str | getline line) > 0) {
                 val = (val == "" ? "" : val "\n") line;
             }
             close(cmd_str);
        } else if (use_rand) {
            val = r_arr[int(rand() * r_n) + 1];
        } else if (s_act) {
            idx = i + skip;
            if (cycle && seq_len > 0) idx = idx % seq_len;
            curr_v = s_start + (idx * s_step);
            val = (is_c) ? sprintf("%c", curr_v) : curr_v;
        } else {
            val = text;
        }

        if (do_num_fmt && cmd_str == "" && !use_rand) {
            num_val = val + 0;
            eps = (num_val >= 0) ? 0.0000000001 : -0.0000000001;
            val = sprintf(f_num, num_val + eps);
        }

        if (fmt != "") val = sprintf(fmt, val);
        val = pre val suf;
        if (width > 0) val = sprintf("%" width "s", val);
        if (use_cnt) val = (i + 1) ": " val;

        if (cols > 1) {
            printf "%s", val;
            if ((i + 1) % cols == 0 || (limit > 0 && i + 1 == limit)) printf "\n";
            else printf "\t";
        } else {
            printf "%s", val;
            if (sep == "\n" || sep == "\t") {
                if (limit == 0 || i + 1 < limit || sep == "\n") printf "%s", sep;
            } else {
                printf "%s", sep;
            }
        }
        fflush("/dev/stdout");

        if (interval > 0) {
            if (system("sleep " interval) != 0) exit 130;
        }
        i++;
    }
}' > "${OUTPUT:-/dev/stdout}"
