#!/bin/sh

if [ "$#" -eq 0 ]; then
    exec yes n
else
    exec yes "$*"
fi
