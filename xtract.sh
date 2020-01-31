#!/bin/bash

# This scripts is meant to be easy-to-use
# Aimed at archives: extract zip, rar, tar, etc...
# Currently all exit statuses are set to 0
# Log file location is set to "$LOG_FILE"
# All files extrated will have full paths
#
# - - - - - - - - CAUTION!!! - - - - - - - -
#
# Some log files might become large
# Consider removing them...
# UNZIP FUNCTION IS USING '-o' AS OPTION WHICH STANDS FOR OVERWRITE!!!

# TODO's:
# * find better way to pass arguments, etc (maybe second argument is the extraction target dir?)

LOG_DIR=$HOME/logs # Log file not in /var/logs due to permission issues
LOG_FILE=$LOG_DIR/$(basename "$0".log)
ROOT_UID=0
#A_NAME=$(basename "$1" | sed -r '$s/\.(zip|rar|bz2|gz|tar.gz|tar.bz2)$//I' | sed -r '$s/ //g') # Strip archive extension
# IF THERE ARE ANY SPACES IN THE NAME ONLY THE FIRST WORD WILL BE USED!!!

logger () {
    echo -e "$@" #SC2086
    echo -e "$(date +\|%T.\[%8N\]\|) $*" > /dev/null >> "${LOG_FILE}" 2>&1
}

spin () {
# Makeshift progress indicator
# It should be used after longer processess
# e.g. extracting, converting, etc.
    i=1
    pid=$!  # get the PID of the external utility. Maybe a better way of doing this...
#             SC2181: Check exit code directly with e.g. 'if mycmd;', not indirectly with $?.
#    sp='%^s&-!@#$*a()_+~' # TODO: Figure out how to randomize chars.
   sp='/-\|'               # <`~~~ these are the actual spinner chars.
    n=${#sp}
    while [[ -d /proc/$pid ]]; do   # PID directory probing
        echo -ne "\b${sp:i++%n:1}"  # Print a character then delete it inplace
        sleep 0.08        #sleep 0.1
    done
    printf -- "\b\033[32mDone\033[0m"
    echo
    sleep 0.5
    return 0 ### TESTING PURPOSES
}

xtract () {
    case "$1" in
        *.zip )
            logger "File format is zip. Checking if unzip is installed"
            if command -v unzip > /dev/null 2>&1; then
                logger "Found unzip"
            else
                echo "unzip is not installed, please install it with your preferred package manager"
                exit 1; fi

            logger "Archive info:\n$(unzip -Z -z -h -t "$1")" > /dev/null 2>&1
            logger "Checking archive integrity"
            if logger "$(unzip -t -q "$1")" > /dev/null 2>&1 &
            then
                spin; fi

            logger "Starting extraction"
            if logger "...$(unzip -o -q "$1")" > /dev/null 2>&1 &
            then
                spin
                logger "Files from '$1' extracted successfuly"
                return 0; fi
            ;;

        *.rar ) # Logging is too bloated
            logger "File format is rar - using unrar. Checking if unrar is installed"
            if command -v unrar > /dev/null 2>&1; then
                logger "Found unrar"
            else
                echo "unrar is not installed, please install it with your preferred package manager"
                exit 1; fi
            logger "Checking archive integrity"
            if logger "$(unrar t -idpdc "$1")" > /dev/null 2>&1 &
            then
                spin; fi
            if logger "$(unrar x -y -o+ -idpdc "$1")" > /dev/null 2>&1 &
            then
                logger "Files from '$1' extracted successfuly"
                return 0; fi
            ;;

#        *.tar ) # UNFINISHED
#            echo "File format is tar - using tar"
#            echo "Checking if tar is installed"
#            tarcheck
#
#            timestamp >> $"LOG_DIR"/$"@".log
#            tar -xvf $"@"
#            ;;
#
#        *.tar.gz )
#            echo "File format is tar.gz - using tar"
#            echo "Checking if tar is installed"
#            tarcheck
#            if [[ $? -eq 0 ]]; then
#                timestamp >> $"LOG_DIR"/$"@".log
#                tar -xzvf $"@" 2>&1 >> $"LOG_DIR"/$"@".log
#                if [[ $? -eq 0 ]]; then
#                    echo "Files from $"@" extracted successfuly" | tee -a $"LOG_DIR"/$"@".log
#                    exit 0; fi
#                else
#                    echo "Errors occured. Aborting..."
#                    exit 1; fi
#            ;;
#
#        *.tar.xz )
#            echo "File format is tar.xz - using tar"
#            echo "Checking if tar is installed"
#            tarcheck
#            if [[ $? -eq 0 ]]; then
#                timestamp >> $"LOG_DIR"/$"@".log
#                tar -xJvf $"@" 2>&1 >> $"LOG_DIR"/$"@".log
#                if [[ $? -eq 0 ]]; then
#                    echo "Files from \$@ extracted successfuly" | tee -a $"LOG_DIR"/$"@".log
#                    exit 0; fi
#                else
#                    echo "Errors occured. Aborting..."
#                    exit 1; fi
#            ;;
#
#        *.tar.bz2 )
#            echo "File format is tar.gz - using tar"
#            echo "Checking if tar is installed"
#            tarcheck
#            if [[ $? -eq 0 ]]; then
#                timestamp >> $"LOG_DIR"/$"@".log
#                tar -xjvf $"@" 2>&1 >> $"LOG_DIR"/$"@".log
#                if [[ $? -eq 0 ]]; then
#                    echo "Files from $"@" extracted successfuly" | tee -a $"LOG_DIR"/$"@".log
#                    exit 0; fi
#                else
#                    echo "Errors occured. Aborting..."
#                    exit 1; fi
#            ;;
#
#        *.7z )
#            echo "File format is 7z - using 7z"
#            echo "Checking if 7z is installed"
#            command -v 7z > /dev/null 2>&1
#            if [[ $? -eq 0 ]]; then
#                echo "7z is installed - proceeding"
#
#                timestamp >> $"LOG_DIR"/$"@".log
#                echo "Checking archive integrity" | tee -a $"LOG_DIR"/$"@".log
#                7z t $"@"  >> $"LOG_DIR"/$"@".log 2>&1
#                if [[ $? -eq 0 ]]; then
#                    echo "Checks went ok. Proceeding with extraction..." | tee -a $"LOG_DIR"/$"@".log
#                    echo "~~~~~~~~~~~~~~~~~ EXTRACTING ~~~~~~~~~~~~~~~~~" | tee -a $"LOG_DIR"/$"@".log
#                    7z x $"@" 2>&1 >> $"LOG_DIR"/$"@".log
#                    if [[ $? -eq 0 ]]; then
#                        echo "Files from $"@" extracted successfuly" | tee -a $"LOG_DIR"/$"@".log
#                        exit 0
#                    else
#                        echo "Errors occured during extraction. Check log file for details. Aborting..."
#                        exit 1; fi
#                else
#                    echo "File is corrupt. Aborting..."
#                    exit 1; fi
#            else
#                echo "7z is not installed, please install it with your preferred package manager"
#                exit 1; fi
#            ;;
#
        * )
            echo "Unknown file format"
            exit 1
            ;;
    esac
}

init () {

    echo >> "${LOG_FILE}"
    logger "~~~~~~~~~~~~~~ xtract.sh xecuted ~~~~~~~~~~~~~"

    if [[ -z $1 ]]; then # If no args are given display basic usage details and exit
        echo "Usage: $(basename "$0" .sh) [path-to-archive] (This will extract the file in your current directory!)"
        exit 1
    elif [[ $UID -eq $ROOT_UID ]]; then # Am I root?
        echo "This script shouldn't be run as root"
        exit 1
    fi # Exit if root

    xtract "$1"
    echo "Log file - ${LOG_FILE}"
}

init "$@"
