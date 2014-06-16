#!/bin/bash

usage() {

    echo "`basename $0` [min max] (min, max: 0x0000..0xffff)"

}

fast_chr() {
    local __octal
    local __char
    printf -v __octal '%03o' $1
    printf -v __char \\$__octal
    REPLY=$__char
}

function unichr {
    local c=$1  # ordinal of char
    local l=0   # byte ctr
    local o=63  # ceiling
    local p=128 # accum. bits
    local s=''  # output string

    (( c < 0x80 )) && { fast_chr "$c"; echo -n "$REPLY"; return; }

    while (( c > o )); do
        fast_chr $(( t = 0x80 | c & 0x3f ))
        s="$REPLY$s"
        (( c >>= 6, l++, p += o+1, o>>=1 ))
    done

    fast_chr $(( t = p | c ))
    echo -n "$REPLY$s "
}

min=0xe000
max=0xe1a0

if test $# -eq 2; then
    min=$1
    max=$2
elif test "$1" = "-h"; then
    usage
    exit 1
fi

## test harness
for (( i=$min; i<$max; i++ )); do
    unichr $i
done
