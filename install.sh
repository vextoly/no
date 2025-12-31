#!/bin/sh
# Author: ihatemustard
# Self-contained installer for the "no" command and its man page

INSTALL_PATH="/usr/local/bin"
MAN_PATH="/usr/local/share/man/man1"

if [ "$(id -u)" -ne 0 ]; then
    echo "You must run this as root!"
    exit 1
fi

case "$1" in
    remove)
        echo "Removing 'no'..."
        rm -f "$INSTALL_PATH/no"
        rm -f "$MAN_PATH/no.1"
        mandb
        echo "Removed."
        exit 0
        ;;
esac

# Create the 'no' command
echo "Creating 'no' command..."
cat > "$INSTALL_PATH/no" << 'EOF'
#!/bin/sh
# Author: ihatemustard
# Simple "no" command with optional --times

times=-1

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --times)
            shift
            times="$1"
            ;;
        *)
            echo "Usage: $0 [--times number]"
            exit 1
            ;;
    esac
    shift
done

print_no() {
    echo "no"
}

if [ "$times" -eq -1 ]; then
    while true; do
        print_no
    done
else
    i=0
    while [ $i -lt "$times" ]; do
        print_no
        i=$((i + 1))
    done
fi
EOF

chmod +x "$INSTALL_PATH/no"

# Create the man page
echo "Creating man page..."
mkdir -p "$MAN_PATH"
cat > "$MAN_PATH/no.1" << 'EOF'
.\" Manpage for no
.TH NO 1 "2025-12-31" "1.0" "no command"
.SH NAME
no \- print "no" repeatedly
.SH SYNOPSIS
.B no
[\-\-times NUMBER]
.SH DESCRIPTION
The
.B no
command prints the word "no".

If
.B --times NUMBER
is given, it prints "no" NUMBER times. If not, it prints infinitely.

.SH EXAMPLES
Print "no" 5 times:

.nf
$ no --times 5
.fi

Print "no" infinitely:

.nf
$ no
.fi

.SH AUTHOR
ihatemustard
EOF

mandb

echo "Installation complete!"
echo "Use 'no --times NUMBER' or 'no' to print infinitely."
