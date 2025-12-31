#!/bin/sh
TARGET="${INSTALL_DIR}/no"


if [ "$(id -u)" -ne 0 ]; then
echo "Error: this script must be run as root (use su or doas)"
exit 1
fi


ACTION="$1"


if [ "$ACTION" = "remove" ]; then
if [ -f "$TARGET" ]; then
rm -f "$TARGET"
echo "'no' removed from $TARGET"
else
echo "'no' is not installed"
fi
exit 0
fi


echo "Installing 'no' to $TARGET..."
mkdir -p "$INSTALL_DIR"


cat > "$TARGET" << 'EOF'
#!/bin/sh


VERSION="1.1"


TEXT="n"
INTERVAL=0
TIMES=0
USE_RANDOM=0
RANDOM_ITEMS=""
USE_COUNT=0
OUTPUT=""
COMMAND=""


usage() {
echo "Usage: no [text] [options]"
exit 0
}


pick_random() {
LIST="$1"
COUNT=$(echo "$LIST" | awk -F',' '{print NF}')
RAND_BYTE=$(od -An -N2 -tu2 /dev/urandom | tr -d ' ')
INDEX=$(( (RAND_BYTE % COUNT) + 1 ))
echo "$LIST" | awk -v i="$INDEX" -F',' '{print $i}'
}


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
*) TEXT="$1"; shift ;;
esac
done


i=0
while [ "$TIMES" -eq 0 ] || [ "$i" -lt "$TIMES" ]; do
if [ -n "$COMMAND" ]; then
OUT=$(sh -c "$COMMAND")
elif [ "$USE_RANDOM" -eq 1 ] && [ -n "$RANDOM_ITEMS" ]; then
OUT=$(pick_random "$RANDOM_ITEMS")
else
OUT="$TEXT"
fi


if [ "$USE_COUNT" -eq 1 ]; then
PREFIX="$((i+1)): "
else
PREFIX=""
fi


if [ -n "$OUTPUT" ]; then
echo "${PREFIX}${OUT}" >> "$OUTPUT"
else
echo "${PREFIX}${OUT}"
fi


i=$((i+1))
awk_exit=$(echo "$INTERVAL > 0" | awk '{exit !$1}')
if [ "$?" -eq 0 ]; then sleep "$INTERVAL"; fi
done
EOF


chmod 755 "$TARGET"
echo "Installed successfully! Test with: no | head"
