#!/usr/bin/env bash

if (( $# < 1 )); then
    echo "Usage: $(basename $0) TASK_NUM"
    echo "Run solution to given task"
    exit 1
fi

tasknum=$(printf "%02d" $1)
nvim --noplugin -u minimal_init.lua -c "luafile $tasknum.lua"
