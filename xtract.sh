#!/bin/bash

# =========================================================
# FILE: xtract.sh
#
# USAGE: xtract.sh [name-of-archive]
#
# DESCRIPTION: A basic bash script which should facilitate
# extracting archives. It extracts the given file to the
# current directoty.
#
# VERSION: 0.3
#
# - - - - - - - - CAUTION!!! - - - - - - - -
#
# This script is work-in-progress
# All progs WILL overwrite any existing files!
# Keep track of log file. Might become large
# Consider removing it

# =========================================================

LOG_DIR=$HOME/logs # Log file not in /var/logs due to permission issues
LOG_FILE=$LOG_DIR/$(basename "$0".log)
ROOT_UID=0
DESTINATION=""
ARGS=("$@")
#A_NAME=$(basename "$1" | sed -r '$s/\.(zip|rar|bz2|gz|tar.gz|tar.bz2)$//I' | sed -r '$s/ //g') # Strip archive extension

trap 'logger "~~~~~~~~~~~~~~ xtract.sh stopped ~~~~~~~~~~~~~"' 1 0

spin () {   # Makeshift progress indicator
            # It should be used after longer processess
            # e.g. extracting, converting, etc.
    i=1
    pid=$!  # get the PID of the external utility. Maybe a better way of doing this...
#             SC2181: Check exit code directly with e.g. 'if mycmd;', not $!
    sp='/-\|'  # <`~~~ these are the actual spinner chars.
    n=${#sp}
    echo -n "... "
    while [[ -d /proc/$pid ]]; do   # PID directory probing
        echo -ne "\b${sp:i++%n:1}"  # Print a character then delete it inplace
        sleep 0.08
    done; printf -- "\b\033[32mDone\033[0m"; echo; sleep 0.05
}

#----------------------------------------------------------------------
#  Pre-extraction checks
#----------------------------------------------------------------------
[[ $# -eq 0 ]] && echo "no args given" && exit 1
[[ $UID -eq $ROOT_UID ]] && echo "This script shouldn't be run as root" && exit 1

chk_archive () {
    logger "Checking $1 with 7z"
    chk_p 7z
    logger "7z output:\n$(7z t "$*" | sed -n 5,18p)" > /dev/null 2>&1 & spin
}

chk_p() { # checks if nedded program is installed
  command -v "$1" >/dev/null 2>&1 || echo "$* not installed"
}

# This is just output redirection for the log file
logger() {
  echo -ne "$@"                                                         #SC2u086; Prints regular output
  echo -e "$(date +\|%T.\[%4N\]\|) $*" >/dev/null >>"${LOG_FILE}" 2>&1 # adds time and the regular output to the logfile
}

#----------------------------------------------------------------------
#  External utility extraction commands
#----------------------------------------------------------------------
x_zip () {
    chk_p unzip
    chk_archive "$1"
    logger "Xtracting $1 with unzip"
    if [[ -z $DESTINATION ]]; then
        logger "...$(unzip -o -q "$1")" > /dev/null 2>&1 & spin
    else logger "...$(unzip -o -q "$1" -d "$DESTINATION")" \
        > /dev/null 2>&1 & spin; fi
}

x_rar () {
    chk_p unrar
    check_archive "$1"
    logger "Xtracting $1 with unrar"
    if [[ -z $DESTINATION ]]; then
        logger "$(unrar x -y -o+ -idpdc "$1")" > /dev/null 2>&1 & spin
    else logger "$(unrar x -y -o+ -idpdc "$1" "$DESTINATION")" \
        > /dev/null 2>&1 & spin; fi
}

x_tar () {
    chk_p tar
    chk_archive "$1"
    logger "Xtracting $1 with tar"
    if [[ -z $DESTINATION ]]; then
        logger "...$(tar xaf "$1")" > /dev/null 2>&1 & spin
    else logger "...$(tar xaf "$1" -C "$DESTINATION")" \
        > /dev/null 2>&1 & spin; fi
}

x_7z () {
    chk_p 7z
    chk_archive "$1"
    logger "Xtracting $1 with 7z"
    if [[ -z $DESTINATION ]]; then
        logger "$(7z x -bb0 -bd -aoa "$1" | sed -n 5,20p)" \
            > /dev/null 2>&1 & spin
    else logger "$(7z x -bb0 -bd -aoa "$1" -o$DESTINATION | sed -n 5,20p)" \
            > /dev/null 2>&1 & spin; fi
}

#----------------------------------------------------------------------
# The actual running part of the script
#----------------------------------------------------------------------
xtract () {       # match files by extension
    case "$1" in
        *.zip)
            x_zip "$1"
            ;;

        *.rar) # Logging is too bloated
            x_rar "$1"
            ;;

        *.tar | *.tar.*)
            x_tar "$1"
            ;;

        *.7z) # Again.. bloated logging
            x_7z "$1"
            ;;

        *)
            echo "Unsupported file format" && exit 1
            ;;
    esac
}

init () { # initialization - basic checks and main script invoker
    echo >> "${LOG_FILE}"
    logger "~~~~~~~~~~~~~~ xtract.sh xecuted ~~~~~~~~~~~~~"; echo
    for i in "${ARGS[@]}"; do
        case "$i" in
            -t=* | --target=*)
                shift
                [ -d "${i#*=}" ] && DESTINATION="${i#*=}" && \
                    logger "Target folder set to $DESTINATION"; echo
                ;;
            *.7z | *.tar | *.tar.* | *.zip | *.rar)
                if xtract "$i"; then
                    logger "Files extracted successfuly" > /dev/null 2>&1
                else
                    logger "Errors occured"; fi
                ;;
        esac
        shift
    done
    echo "Log file - ${LOG_FILE}"
}

init "$@"
