#!/bin/sh

source $(dirname $0)/config.sh

OUT=$default_output

function fg() {
    case $1 in
        bar)    echo "\f$2" ;;
        tmux)   echo "#[fg=${colors[$2]}]" ;;
        none)   echo "" ;;
        ?)      echo "\f$2" ;;
    esac
}

function bg() {
    case $1 in
        bar)    echo "\b$2" ;;
        tmux)   echo "#[bg=$2]" ;;
        none)   echo "" ;;
        ?)      echo "\b$2" ;;
    esac
}

# print formatted output. need 2 params: display <value> <icon>
function display () {
    if [ -n "$1" ]; then
        echo -n     "$(fg $OUT ${hl})"
        echo -en    "$2 "
        echo        "$(fg $OUT ${fg})$1"
    fi
}

function workspaces () {
    dskp_num=$(xprop -root _NET_NUMBER_OF_DESKTOPS | cut -d ' ' -f3)
    dskp_cur=$(xprop -root _NET_CURRENT_DESKTOP | cut -d ' ' -f3)

    buffer=""

    for w in $(seq 1 $(($dskp_num-1))); do
        if [ "$w" -eq "$dskp_cur" ]; then
            buffer="$buffer$(echo -e '\ue190')"
            #buffer="$buffer\u${fg} ${dskp_tag[$w]} \u${bg}"
        else
            buffer="$buffer$(fg $OUT ${hl})$(echo -e '\ue190')$(fg $OUT ${fg})"
            #buffer="$buffer ${dskp_tag[$w]} "
        fi
    done

    echo -n "${buffer}"
}

function ratgrp() {
    dskp_tag=('' 'MEH' 'WEB' 'DEV')
    dskp_cur=$(ratpoison -c 'groups' | cut -sd'*' -f1)
    dskp_num=$(ratpoison -c 'groups'| wc -l)

    val=""

    for w in $(seq 1 $dskp_num); do
        if [ "$w" -eq "$dskp_cur" ]; then
             val="$val\u${fg} ${dskp_tag[$w]} \u${bg}"
         else
            val="$val ${dskp_tag[$w]} "
        fi
    done

    echo -n "${val}"
}

function groups() {
    if [ "$(xprop -root _NET_WM_NAME|cut -d\" -f2)" = "ratpoison" ]; then
        echo "$(ratgrp)"
    else
        echo "$(workspaces)"
    fi
}

function mails () {
    new=$(~/bin/mcount ~/var/mail/INBOX/new/)
    #cur=$(~/bin/mcount ~/var/mail/INBOX/cur/)
    #val="$new/$cur"
    val="$new"
    ico=${i_mail}

    display "$val" "$ico"
}

function mpd_now_playing () {
    val=$(mpc current --format "$mpc_format" 2>/dev/null)
    ico=${i_musk}

    if [[ -z $val ]]; then
        val=''
        ico=''
    fi

    display "$val" "$ico"
}

function volume () {
    val=$(amixer sget $alsa_channel | sed -n 's/.*\[\([0-9/]*%\)\].*/\1/p' | uniq)
    ico=${i_alsa}

    display "$val" "$ico"
}

function battery () {
    val=$(acpi -b | sed 's/^.* \([0-9]*%\).*$/\1/')
    ico=${i_batt}

    display "$val" "$ico"
}

function packages () {

    val=$"$(pacman -Q| wc -l) pkg"
    ico=${i_pkgs}

    display "$val" "$ico"
}

function memory () {

    mem_tot=$(free -m| sed -n 2p| awk '{print $2}')
    mem_use=$(free -m| sed -n 3p| awk '{print $3}')
    val="$(echo "$mem_use*100/$mem_tot" | bc)%"
    ico=${i_memy}

    display "$val" "$ico"
}

function gputemp () {

    val="$(nvidia-smi -q -d TEMPERATURE | grep Gpu | sed 's/.*: //')"
    ico=${i_grap}

    display "$val" "$ico"
}

function gpufanspeed () {

    val="$(nvidia-smi -q | grep "Fan" | sed 's/.*: \([0-9]*\).*$/\1/')%"
    ico=${i_fans}

    display "$val" "$ico"
}

function processes () {

    val="$(iostat -c | sed -n "4p" | awk -F " " '{print $1}')%"
    ico=${i_load}

    display "$val" "$ico"
}

function network () {

    interface_up=$(ip link | grep 'state UP' | wc -l)

    if [ ${interface_up} -gt 1 ]; then 
        val="multi connection"
        ico=${i_netw}
    else

        net_interface=$(ip link| grep 'state UP'|
            sed 's/[0-9]: \([^:]*\):.*$/\1/')
        if [ "$net_interface" = "$net_wire" ]; then
            val=$(ip addr show $net_interface| grep 'inet '|
                                            sed 's#.* \(.*\)/.*$#\1#')
            ico=${i_netw}
        elif [ "$net_interface" = "$net_wifi" ]; then
            val=$(ip addr show $net_interface| grep 'inet '|
                                            sed 's#.* \(.*\)/.*$#\1#')
            ico=${i_wifi}
        else
            val=""
            ico=${i_netw}
        fi
    fi

    [[ -z "$val" ]] && val="disconnected"

    display "$val" "$ico"
}

function clock () {
    val=$(date +${date_format})
    ico=${i_time}

    display "$val" "$ico"
}

function fillbar () {
    while getopts "B:F:H:LCRO:s:bcflmnprtvw" opt; do
        case $opt in
            # Specific options for bar-aint-recursive
            B) bg=$OPTARG ;;    # background color
            F) fg=$OPTARG ;;    # foreground color
            H) hl=$OPTARG ;;    # highlights color
            L) buffer="${buffer}\l " ;;              # left justify
            C) buffer="${buffer}\c " ;;              # center text
            R) buffer="${buffer}\r " ;;              # right justify

            # Which program is the output intended for ? (bar|tmux|none)
            O) OUT=$OPTARG ;;

            # Content of the output
            b) [[ -n "$(battery)" ]] && buffer="${buffer}$(battery) ${sp}"           ;;
            c) [[ -n "$(clock)" ]] && buffer="${buffer}$(clock) ${sp}"             ;;
            f) [[ -n "$(gpufanspeed)" ]] && buffer="${buffer}$(gpufanspeed) ${sp}"       ;;
            l) [[ -n "$(mpd_now_playing)" ]] && buffer="${buffer}$(mpd_now_playing) ${sp}"   ;;
            m) [[ -n "$(mails)" ]] && buffer="${buffer}$(mails) ${sp}"             ;;
            n) [[ -n "$(network)" ]] && buffer="${buffer}$(network) ${sp}"           ;;
            p) [[ -n "$(processes)" ]] && buffer="${buffer}$(processes) ${sp}"         ;;
            r) [[ -n "$(memory)" ]] && buffer="${buffer}$(memory) ${sp}"            ;;
            t) [[ -n "$(gputemp)" ]] && buffer="${buffer}$(gputemp) ${sp}"           ;;
            v) [[ -n "$(volume)" ]] && buffer="${buffer}$(volume) ${sp}"            ;;
            w) [[ -n "$(groups)" ]] && buffer="${buffer}$(groups) ${sp}"            ;;
        esac
    done

    # Set the default fg/bg and remove trailing separator (if any)
    echo "$(bg $OUT ${bg})$(fg $OUT ${fg}) $buffer " | sed "s/${sp}$//"
}

fillbar $@
