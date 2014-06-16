#!/bin/bash
#
# (c) wtfpl by z3bra
# deptree; List dependencies that are installed ONLY for <packages>


test $# -ne 1 && echo "`basename $0 <package>`" && exit 1

deplist=''
level=0

# needless to bother with any f**king locale here
export LC_ALL=en_US

indent() {
    for i in `seq 0 $1`; do
        echo -n '  '
    done
}

dependent() {
    IFS=' ><=' read pkg version<<< "$1"

    exec 2>/dev/null
    dep=`pacman -Qi $pkg | grep 'Required By' | sed 's/^.*: //'`
    opt=`pacman -Qi $pkg | grep 'Optional Deps' | sed 's/^.*: //'`

    test "$dep" = "None" && echo $opt || echo $dep
}

deplist() {
    IFS=' ><=' read pkg version<<< "$1"

    exec 2>/dev/null
    pacman -Qi $pkg | grep 'Depends On' | sed 's/^.*: //' | grep -Ev 'None|--'
}

listdep() {
    list=`deplist $1 | sed 's/[<>=]*[.0-9]*//g'`

    for pkg in $list; do
        isdep=`dependent $pkg`
        test "$1" = "$isdep" && echo $pkg
    done
}

listdep $1
