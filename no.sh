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
    echo "n"
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
