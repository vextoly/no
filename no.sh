#!/bin/sh

export LC_ALL=C

VERSION="1.6-r1"

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
OUTPUTS=""
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
JITTER=0
CASE_MODE=""
STYLE=""
HEADER=""
FILTER_REGEX=""
CALC_EXPR=""
TEMPLATE_FILE=""
UNIQUE=0
TRIM=0

usage() {
    cat <<EOF
Usage: no [text] [options]

Core Options:
  -t, --times <n>      Stop after N outputs (0=infinite)
  -i, --interval <sec> Sleep between outputs
  -j, --jitter <sec>    Add random 0-N sec delay to interval
  -o, --output <file>  Write to file (can be used multiple times)
  -r, --random <list>  Pick random item from comma-separated list
  -cmd, --command <q>  Execute shell command (captures all output)
  -v, --version        Show version
  -h, --help           Show this help message

Processing & Logic:
  --filter <regex>     Only output items matching regex
  --calc <op>          Perform arithmetic on numbers (e.g., '+5', '*2', '/2')
  --template <file>    Use file content as input template
  --unique             Ensure every output item is unique
  --trim               Remove leading/trailing whitespace

Formatting:
  -f, --format <str>    Printf-style format (e.g., "ID-%s")
  -s, --separator <str> Character(s) between items (default: \n)
  -cols <n>             Output in N columns (uses tabs)
  -c, --count           Prepend line counter (1: , 2: , etc.)
  --case <mode>         Transform text: 'upper', 'lower', or 'swap'
  --style <opts>        Style: bold, underline, italic, hex:#RRGGBB, or color name
  --header <str>        Print a line once before starting
  --prefix <str>        Add string before each output
  --suffix <str>        Add string after each output
  --width <n>           Right-align output to fixed width

Sequences:
  --seq <start:end>    Generate sequence (1:100, a:z, -5:5)
  --step <n>           Sequence increment size
  --cycle              Repeat sequence infinitely (requires -t)
  --skip <n>           Skip first N items
  --pad <n>            Zero-pad numbers (e.g., 001, 002)
  --precision <n>      Decimal places for floats
  --verify             Run internal self-tests

Kill Switch:
  CTRL + E             Instantly kills the process and returns to shell.
EOF
    exit 0
}

verify_script() {
    printf -- "Starting verification suite for v$VERSION...\n"
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
    case "$0" in /*|./*) script_path="$0" ;; *) script_path="./$0" ;; esac
    FAILED_TESTS=0
    TOTAL_TESTS=0

    TMP_TPL="no_test_tpl.$$.txt"
    printf "Line1\nLine2" > "$TMP_TPL"

    test_case() {
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        NAME="$1"; CMD="$2"; EXPECTED_RAW="$3"
        EXPECTED=$(printf -- "$EXPECTED_RAW")
        RESULT=$(eval "$script_path $CMD" 2>/dev/null)
        if [ "$RESULT" = "$EXPECTED" ]; then
            printf -- "${GREEN}[PASS]${NC} %s\n" "$NAME"
        else
            printf -- "${RED}[FAIL]${NC} %s\n" "$NAME"
            printf -- "    Expected: [%s]\n" "$EXPECTED_RAW"
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
    test_case "Parsing with =" "--times=2 'hi'" "hi\nhi\n"
    test_case "Parsing -- delimiter" "-t 1 -- -f" "-f\n"
    test_case "Case Upper" "-t 1 'hi' --case upper" "HI\n"
    test_case "Case Lower" "-t 1 'HI' --case lower" "hi\n"
    test_case "Header" "-t 1 'row' --header 'ID,Name'" "ID,Name\nrow\n"
    test_case "Color" "-t 1 'err' --color red" "\033[31merr\033[0m\n"
    test_case "Filter Basic" "--seq 1:5 --filter '3'" "3\n"
    test_case "Filter Regex" "--seq 10:20 --filter '1[5-6]'" "15\n16\n"
    test_case "Filter Empty Result" "--seq 1:5 --filter '9'" ""
    test_case "Calc Add" "-t 1 '10' --calc '+5'" "15\n"
    test_case "Calc Subtract" "-t 1 '10' --calc '-5'" "5\n"
    test_case "Calc Multiply" "-t 1 '10' --calc '*2'" "20\n"
    test_case "Calc Divide" "-t 1 '10' --calc '/2'" "5\n"
    test_case "Calc Sequence" "--seq 1:3 --calc '*10'" "10\n20\n30\n"
    test_case "Style Bold" "-t 1 'b' --style bold" "\033[1mb\033[0m\n"
    test_case "Style Underline" "-t 1 'u' --style underline" "\033[4mu\033[0m\n"
    test_case "Style Hex" "-t 1 'h' --style hex:#FF0000" "\033[38;2;255;0;0mh\033[0m\n"
    test_case "Style Mixed" "-t 1 'm' --style bold,underline" "\033[1;4mm\033[0m\n"
    test_case "Template File" "--template $TMP_TPL -t 1" "Line1\nLine2\n"
    test_case "Template + Format" "--template $TMP_TPL -t 1 -f '>%s<'" ">Line1\nLine2<\n"
    test_case "Filter non-matching text" "-t 1 'abc' --filter 'z'" ""
    test_case "Calc Negative Input" "-t 1 '-5' --calc '*2'" "-10\n"
    test_case "Style Case Combo" "-t 1 'a' --case upper --style bold" "\033[1mA\033[0m\n"
    test_case "Multi-placeholder Format" "-t 1 'DATA' -f '>>> %s <<< [ %s ]'" ">>> DATA <<< [ DATA ]\n"
    test_case "Unique Flag" "--seq a:c --cycle --unique -t 3" "a\nb\nc\n"
    test_case "Trim Flag" "-t 1 '  trimmed  ' --trim" "trimmed\n"

    rm -f "$TMP_TPL"

    printf -- "----------------------------------------------\n"
    [ $FAILED_TESTS -eq 0 ] && printf "${GREEN}SUCCESS: All tests passed.${NC}\n" || printf "${RED}FAILURE: $FAILED_TESTS tests failed.${NC}\n"
    exit $FAILED_TESTS
}

check_arg() {
    if [ -z "$2" ]; then echo "Error: Argument for $1 is missing."; exit 1; fi
    case "$2" in -[0-9]*) ;; -*) echo "Error: Argument for $1 cannot be a flag ($2)."; exit 1 ;; esac
}

while [ $# -gt 0 ]; do
    KEY="$1"
    if [ "$KEY" = "--" ]; then
        shift
        if [ $# -gt 0 ]; then TEXT="$1"; shift; fi
        while [ $# -gt 0 ]; do TEXT="$TEXT $1"; shift; done
        break
    fi
    case "$KEY" in
        --*=*) OPT="${KEY%%=*}"; VAL="${KEY#*=}"; shift; set -- "$OPT" "$VAL" "$@"; continue ;;
    esac
    case "$1" in
        --verify) verify_script ;;
        -v|--version) echo "no v$VERSION"; exit 0 ;;
        -h|--help) usage ;;
        -cmd|--command) check_arg "$1" "$2"; COMMAND_STR="$2"; shift ;;
        -r|--random) check_arg "$1" "$2"; USE_RANDOM=1; RANDOM_ITEMS="$2"; shift ;;
        -c|--count) USE_COUNT=1 ;;
        -o|--output) check_arg "$1" "$2"; OUTPUTS="$OUTPUTS '$2'"; shift ;;
        -t|--times) check_arg "$1" "$2"; TIMES="$2"; shift ;;
        -f|--format) check_arg "$1" "$2"; FORMAT="$2"; shift ;;
        -s|--separator) check_arg "$1" "$2"; SEPARATOR="$2"; shift ;;
        -cols) check_arg "$1" "$2"; COLUMNS="$2"; shift ;;
        -i|--interval) check_arg "$1" "$2"; INTERVAL="$2"; shift ;;
        --prefix) check_arg "$1" "$2"; PREFIX_STR="$2"; shift ;;
        --suffix) check_arg "$1" "$2"; SUFFIX_STR="$2"; shift ;;
        --width) check_arg "$1" "$2"; WIDTH="$2"; shift ;;
        --cycle) CYCLE=1 ;;
        --skip) check_arg "$1" "$2"; SKIP="$2"; shift ;;
        --seq) check_arg "$1" "$2"; SEQ_ACTIVE=1; SEQ_START="${2%%:*}"; SEQ_END="${2#*:}"; shift ;;
        --step) check_arg "$1" "$2"; STEP="$2"; shift ;;
        --pad) check_arg "$1" "$2"; PAD="$2"; shift ;;
        --precision|--prec) check_arg "$1" "$2"; PRECISION="$2"; shift ;;
        -j|--jitter) check_arg "$1" "$2"; JITTER="$2"; shift ;;
        --case) check_arg "$1" "$2"; CASE_MODE="$2"; shift ;;
        --color) check_arg "$1" "$2"; STYLE="$2"; shift ;;
        --style) check_arg "$1" "$2"; STYLE="$2"; shift ;;
        --header) check_arg "$1" "$2"; HEADER="$2"; shift ;;
        --filter) check_arg "$1" "$2"; FILTER_REGEX="$2"; shift ;;
        --calc) check_arg "$1" "$2"; CALC_EXPR="$2"; shift ;;
        --template) check_arg "$1" "$2"; TEMPLATE_FILE="$2"; shift ;;
        --unique) UNIQUE=1 ;;
        --trim) TRIM=1 ;;
        -[0-9]*) TEXT="$1" ;;
        -*) echo "Unknown option: $1"; exit 1 ;;
        *) TEXT="$1" ;;
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
    if [ "$TIMES" -eq 0 ] && [ "$CYCLE" -eq 0 ] && [ -z "$FILTER_REGEX" ]; then
        TIMES=$((SEQ_LEN - SKIP))
        [ "$TIMES" -le 0 ] && SHOULD_EXIT=1
    fi
else
    if [ "$SKIP" -gt 0 ] && [ "$TIMES" -gt 0 ] && [ -z "$FILTER_REGEX" ]; then
        TIMES=$((TIMES - SKIP))
        [ "$TIMES" -le 0 ] && SHOULD_EXIT=1
    fi
fi

if [ "$SHOULD_EXIT" -eq 1 ]; then exit 0; fi

if [ -n "$OUTPUTS" ]; then
    OUT_CMD="tee $OUTPUTS >/dev/null"
else
    OUT_CMD="cat"
fi

awk -v text="$TEXT" -v limit="$TIMES" -v use_rand="$USE_RANDOM" \
    -v r_list="$RANDOM_ITEMS" -v use_cnt="$USE_COUNT" -v cols="$COLUMNS" \
    -v sep="$SEPARATOR" -v fmt="$FORMAT" -v s_act="$SEQ_ACTIVE" \
    -v s_start="$START_VAL" -v s_step="$STEP" -v is_c="$IS_CHAR_SEQ" \
    -v pad="$PAD" -v prec="$PRECISION" -v interval="$INTERVAL" \
    -v pre="$PREFIX_STR" -v suf="$SUFFIX_STR" -v width="$WIDTH" \
    -v cycle="$CYCLE" -v skip="$SKIP" -v seq_len="$SEQ_LEN" \
    -v cmd_str="$COMMAND_STR" -v jitter="$JITTER" -v case_mode="$CASE_MODE" \
    -v style_str="$STYLE" -v header="$HEADER" \
    -v filter_rx="$FILTER_REGEX" -v calc_op="$CALC_EXPR" \
    -v tpl_file="$TEMPLATE_FILE" -v unique="$UNIQUE" -v trim_flag="$TRIM" \
'
function hex2dec(h, i, x, v) {
    h = toupper(h); sub(/^#/, "", h); v = 0;
    for(i=1; i<=length(h); i++) {
        x = index("0123456789ABCDEF", substr(h, i, 1)) - 1;
        v = v * 16 + x;
    }
    return v;
}
BEGIN {
    if (sep == "\\n") sep = "\n";
    else if (sep == "\\t") sep = "\011";

    if (use_rand || jitter > 0) { srand(); }
    if (use_rand) { r_n = split(r_list, r_arr, ","); }

    if (tpl_file != "") {
        text = "";
        while ((getline line < tpl_file) > 0) {
            text = (text == "" ? "" : text "\n") line
        }
        close(tpl_file)
    }

    c_s=""; c_e=""
    if (style_str != "") {
        n_st = split(style_str, st_arr, ",");
        c_s = "\033[";
        has_st = 0;
        for (k=1; k<=n_st; k++) {
            s = st_arr[k];
            code = "";
            if (s == "bold") code="1";
            else if (s == "dim") code="2";
            else if (s == "italic") code="3";
            else if (s == "underline") code="4";
            else if (s == "red") code="31";
            else if (s == "green") code="32";
            else if (s == "yellow") code="33";
            else if (s == "blue") code="34";
            else if (s == "magenta") code="35";
            else if (s == "cyan") code="36";
            else if (s ~ /^hex:/ || s ~ /^#/) {
                sub(/^hex:/, "", s);
                v = hex2dec(s);
                r = int(v / 65536); g = int((v % 65536) / 256); b = int(v % 256);
                code = "38;2;" r ";" g ";" b;
            }
            if (code != "") { if (has_st) c_s = c_s ";"; c_s = c_s code; has_st=1; }
        }
        c_s = c_s "m"; c_e = "\033[0m";
    }

    pre = c_s pre; suf = suf c_e;
    if (header != "") { printf "%s\n", header }

    do_num_fmt = (!is_c && (pad > 0 || prec >= 0));
    if (do_num_fmt) f_num = "%" (pad > 0 ? "0" pad : "") (prec >= 0 ? "." prec : "") (prec >= 0 ? "f" : "d");

    i = 0;
    iter_total = 0;
    while (limit == 0 || i < limit) {
        should_print = 1;

        if (cmd_str != "") { val = ""; while ((cmd_str | getline ln) > 0) { val = (val == "" ? "" : val "\n") ln; }; close(cmd_str); }
        else if (use_rand) { val = r_arr[int(rand() * r_n) + 1]; }
        else if (s_act) {
            idx = iter_total + skip;
            if (!cycle && idx >= seq_len && seq_len > 0) break;
            if (cycle && seq_len > 0) idx = idx % seq_len;
            cv = s_start + (idx * s_step); val = (is_c) ? sprintf("%c", cv) : cv;
        }
        else {
            val = text;
            if (limit > 0 && !use_rand && !cycle && iter_total >= limit && filter_rx != "") break;
        }

        if (trim_flag) { sub(/^[ \t\r\n]+/, "", val); sub(/[ \t\r\n]+$/, "", val); }

        if (calc_op != "" && val ~ /^-?[0-9]+(\.[0-9]+)?$/) {
            op_char = substr(calc_op, 1, 1);
            op_val = substr(calc_op, 2) + 0;
            if (op_char == "+") val = val + op_val;
            else if (op_char == "-") val = val - op_val;
            else if (op_char == "*") val = val * op_val;
            else if (op_char == "/") { if (op_val != 0) val = val / op_val; }
        }

        if (filter_rx != "" && val !~ filter_rx) {
            should_print = 0;
        }
        else if (unique && seen[val]++) {
            should_print = 0;
            if (!use_rand && !s_act && !cycle) break;
        }
        else {
            if (do_num_fmt && cmd_str == "" && !use_rand && val ~ /^-?[0-9]+(\.[0-9]+)?$/) {
                nv = val + 0; eps = (nv >= 0) ? 0.0000000001 : -0.0000000001; val = sprintf(f_num, nv + eps);
            }

            if (case_mode == "upper") val = toupper(val); else if (case_mode == "lower") val = tolower(val);
            else if (case_mode == "swap") {
                nv = ""; for(k=1; k<=length(val); k++) { ch = substr(val, k, 1); if (ch ~ /[a-z]/) nv = nv toupper(ch); else if (ch ~ /[A-Z]/) nv = nv tolower(ch); else nv = nv ch }
                val = nv
            }

            if (fmt != "") {
                n_fmt = fmt; gsub(/%%/, "\001", n_fmt); pc = 0;
                for(k=1; k<=length(n_fmt); k++) if(substr(n_fmt, k, 1) == "%") pc++;
                gsub(/\001/, "%%", n_fmt);
                if (pc == 1) val = sprintf(fmt, val);
                else if (pc == 2) val = sprintf(fmt, val, val);
                else if (pc == 3) val = sprintf(fmt, val, val, val);
                else if (pc == 4) val = sprintf(fmt, val, val, val, val);
                else val = sprintf(fmt, val);
            }
            val = pre val suf;
            if (width > 0) val = sprintf("%" width "s", val);
            if (use_cnt) val = (i + 1) ": " val;
        }

        iter_total++;

        if (should_print) {
            if (cols > 1) { printf "%s", val; if ((i + 1) % cols == 0 || (limit > 0 && i + 1 == limit)) printf "\n"; else printf "\011"; }
            else { printf "%s", val; printf "%s", sep; }

            if (interval > 0 || jitter > 0) {
                fflush("/dev/stdout"); wt = interval; if (jitter > 0) wt += (rand() * jitter);
                if (wt > 0) if (system("sleep " wt) != 0) exit 130;
            }
            i++;
        }
    }
}' | eval "$OUT_CMD"
