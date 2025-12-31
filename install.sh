#!/bin/sh
# Author: ihatemustard
# Installer for the "no" command

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
        echo "Removed."
        exit 0
        ;;
esac

# Create the 'no' command
echo "Creating 'no' command..."
cat > "$INSTALL_PATH/no" << 'EOF'
#!/bin/sh
# Author: ihatemustard
# Flexible "no" command

times=-1
word="n"

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --times)
            shift
            times="$1"
            ;;
        *)
            word="$1"
            ;;
    esac
    shift
done

print_word() {
    echo "$word"
}

if [ "$times" -eq -1 ]; then
    while true; do
        print_word
    done
else
    i=0
    while [ $i -lt "$times" ]; do
        print_word
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
no \- print "n" or a custom word repeatedly
.SH SYNOPSIS
.B no
[\fIWORD\fR] [\-\-times NUMBER]
.SH DESCRIPTION
The
.B no
command prints the letter "n" by default.

If a
\fIWORD\fR
is provided, it prints that word repeatedly.

Use
.B --times NUMBER
to print a specific number of times. Without it, the command prints infinitely.

.SH EXAMPLES
Print "n" infinitely:

.nf
$ no
.fi

Print "hi" infinitely:

.nf
$ no hi
.fi

Print "hi" twice:

.nf
$ no hi --times 2
.fi

Print "n" 5 times:

.nf
$ no --times 5
.fi

.SH AUTHOR
ihatemustard
EOF

echo "Installation complete!"
echo "Use 'no WORD --times NUMBER' or 'no WORD' to print infinitely."
