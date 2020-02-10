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
# VERSION: 0.2

# This scripts is meant to be easy-to-use
# Aimed at archives: extract zip, rar, tar, etc...
# Currently all exit statuses are set to 0
# Log file location is set to "$LOG_FILE"
# All files extrated will have full paths
#
# - - - - - - - - CAUTION!!! - - - - - - - -
#
# All progs WILL overwrite any existing files!
# Keep track of log file. Might become large
# Consider removing it

# =========================================================

LOG_DIR=$HOME/logs # Log file not in /var/logs due to permission issues
LOG_FILE=$LOG_DIR/$(basename "$0".log)
ROOT_UID=0
#ARGS_COUNT=2 # unused yet TODO
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
    while [[ -d /proc/$pid ]]; do   # PID directory probing
        echo -ne "\b${sp:i++%n:1}"  # Print a character then delete it inplace
        sleep 0.08
    done
    printf -- "\b\033[32mDone\033[0m"
    echo
    sleep 0.05
}



#----------------------------------------------------------------------
#  Pre-extraction checks
#----------------------------------------------------------------------

if [[ -z $1 ]]; then # If no args are given display basic usage details and exit
    echo "Usage: $(basename "$0" .sh) [path-to-archive] \
    (This will extract the file in your current directory!)"
    exit 1                                                          # Exit if no args given
elif [[ $UID -eq $ROOT_UID ]]; then # second check - Am I root?
    echo "This script shouldn't be run as root"
    exit 1; fi                                                      # Exit if root


chk_p () { # checks if nedded program is installed
    command -v "$*" > /dev/null 2>&1 || echo "$* not installed"
}

chk_archive () {
    logger "Checking archive ${1} with 7z utility"
    chk_p 7z
    if logger "7z output:\n$(7z t "$*" | sed -n 5,18p)" > /dev/null 2>&1 &
    then spin
    else
        echo "error with archive integrity"; exit 1; fi
}

logger () { # This is just output redirection for the log file
    echo -e "$@" #SC2u086; Prints regular output
    echo -e "$(date +\|%T.\[%4N\]\|) $*" > /dev/null >> "${LOG_FILE}" 2>&1 # adds time and the regular output to the logfile
}



#----------------------------------------------------------------------
#  External utiliry extraction commands
#----------------------------------------------------------------------

x_zip () {
    chk_p unzip
    chk_archive "$1"
    if logger "...$(unzip -o -q "$1")" > /dev/null 2>&1 &
    then spin; fi;
}

x_rar () {
    chk_p unrar
    check_archive "$1"
    if logger "$(unrar x -y -o+ -idpdc "$1")" > /dev/null 2>&1 &
    then spin; fi
}

x_tar () {
    chk_p tar
    chk_archive "$1"
    if logger "...$(tar xaf "$1")" > /dev/null 2>&1 &
    then spin; fi
}

x_7z () {
    chkr 7z
    chk_archive "$1"
    if logger "$(7z x -bb0 -bd -aoa "$1" | sed -n 5,20p)" > /dev/null 2>&1 &
    then spin; fi
}



#----------------------------------------------------------------------
# The actual running part of the script
#----------------------------------------------------------------------

xtract () {       # match files by extension
    case "$1" in
        *.zip )
            x_zip "$1"
            ;;

        *.rar ) # Logging is too bloated
            x_rar "$1"
            ;;

        *.tar | *.tar.* )
            x_tar "$1"
            ;;

        *.7z) # Again.. bloated logging
            x_7z "$1"
            ;;

        * )
            echo "Unsupported file format"; exit 1
            ;;
    esac
}

init () { # initialization - basic checks and main script invoker
    echo >> "${LOG_FILE}"
    logger "~~~~~~~~~~~~~~ xtract.sh xecuted ~~~~~~~~~~~~~"
    if xtract "$1"; then logger "Files from '$1' extracted successfuly"; else "Errors occured"; fi
    echo "Log file - ${LOG_FILE}"
}

init "$@"
