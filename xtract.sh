#!/bin/sh
# This scripts is meant to be easy-to-use
# Aimed at archives: extract zip, rar, tar, etc...

logloc=$HOME/logs

spin() {
    i=1
    pid=$!
    sp='%^s&-!@\b#$*a()_+~' # sp='/-\|'
    n=${#sp}
    while [[ -d /proc/$pid ]]; do
        echo -ne "\b${sp:i++%n:1}"
        sleep 0.08
        #sleep 0.1
    done
    printf -- "\b\033[32mDone\033[0m"
    sleep 0.5
    echo
}

info () {
    echo "INFO:"
    echo "Current log file location is set to $logloc"
    echo "All files extrated will have full paths"
    sleep 0.4
    echo
    echo -e "\t- - - - - - - - CAUTION!!! - - - - - - - -"
    echo
    sleep 0.4
    echo -e "\tSome log files might become large in size"
    echo -e "\tConsider removing them..."
    echo
}

timestamp () {
    date +"- - - - - - - - %F %R - - - - - - - - "
}

tarcheck () {
    command -v tar > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "tar is installed - proceeding"
        return 0
    else
        echo "tar is not installed, please install it with your preferred package manager"
        return 1
    fi
}

xtract () {
    case "$@" in
        *.zip )
            echo "File format is zip - using unzip"
            echo "Checking if unzip is installed"
            command -v unzip > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                echo "unzip is installed - proceeding"

                timestamp >> $logloc/$@.log
                echo "Checking archive integrity" | tee -a $logloc/$@.log
                unzip -t $@ 2>&1 >> $logloc/$@.log &
                spin
                if [[ $? -eq 0 ]]; then
                    echo "Checks went ok. Proceeding with extraction..." | tee -a $logloc/$@.log
                    echo "~~~~~~~~~~~~~~~~~ EXTRACTING ~~~~~~~~~~~~~~~~~" | tee -a $logloc/$@.log
                    unzip -o $@ 2>&1 >> $logloc/$@.log &
                    spin
                    if [[ $? -eq 0 ]]; then
                        echo "Files from $@ extracted successfuly" | tee -a $logloc/$@.log
                        exit 0
                    else
                        echo "Errors occured during extraction. Check log file for details. Aborting..."
                        exit 1; fi
                else
                    echo "File is corrupt. Aborting..."
                    exit 1; fi
            else
                echo "unzip is not installed, please install it with your preferred package manager"
                exit 1; fi
            ;;

        *.rar ) # UNFINISHED
                # TODO: format properly
                #       maybe some spinner?
            echo "File format is rar - using unrar"
            echo "Checking if unrar is installed"
            command -v unrar > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                echo "unrar is installed - proceeding"
                echo "Checking archive integrity"
                unrar t $@  >> $logloc/$@.log 2>&1
                if [[ $? -eq 0 ]]; then
                    echo "Tested ok. Proceeding to extract..."
                    unrar x $@ 2>&1 >> $logloc/$@.log
                    if [[ $? -eq 0 ]]; then
                        echo "Files from $@ extracted successfuly" | tee -a $logloc/$@.log
                        exit 0
                    else
                        echo "Errors occured during extraction. Check log file for details. Aborting..."
                        exit 1; fi
                else
                    echo "File is corrupt. Aborting..."
                    exit 1; fi
            else
                echo "unrar is not installed, please install it with your preferred package manager"
                exit 1; fi
            ;;

        *.tar ) # UNFINISHED
            echo "File format is tar - using tar"
            echo "Checking if tar is installed"
            tarcheck

            timestamp >> $logloc/$@.log
            tar -xvf $@
            ;;

        *.tar.gz )
            echo "File format is tar.gz - using tar"
            echo "Checking if tar is installed"
            tarcheck
            if [[ $? -eq 0 ]]; then
                timestamp >> $logloc/$@.log
                tar -xzvf $@ 2>&1 >> $logloc/$@.log
                if [[ $? -eq 0 ]]; then
                    echo "Files from $@ extracted successfuly" | tee -a $logloc/$@.log
                    exit 0; fi
                else
                    echo "Errors occured. Aborting..."
                    exit 1; fi
            ;;

        *.tar.xz )
            echo "File format is tar.xz - using tar"
            echo "Checking if tar is installed"
            tarcheck
            if [[ $? -eq 0 ]]; then
                timestamp >> $logloc/$@.log
                tar -xJvf $@ 2>&1 >> $logloc/$@.log
                if [[ $? -eq 0 ]]; then
                    echo "Files from $@ extracted successfuly" | tee -a $logloc/$@.log
                    exit 0; fi
                else
                    echo "Errors occured. Aborting..."
                    exit 1; fi
            ;;

        *.tar.bz2 )
            echo "File format is tar.gz - using tar"
            echo "Checking if tar is installed"
            tarcheck
            if [[ $? -eq 0 ]]; then
                timestamp >> $logloc/$@.log
                tar -xjvf $@ 2>&1 >> $logloc/$@.log
                if [[ $? -eq 0 ]]; then
                    echo "Files from $@ extracted successfuly" | tee -a $logloc/$@.log
                    exit 0; fi
                else
                    echo "Errors occured. Aborting..."
                    exit 1; fi
            ;;

        *.7z )
            echo "File format is 7z - using 7z"
            echo "Checking if 7z is installed"
            command -v 7z > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                echo "7z is installed - proceeding"

                timestamp >> $logloc/$@.log
                echo "Checking archive integrity" | tee -a $logloc/$@.log
                7z t $@  >> $logloc/$@.log 2>&1
                if [[ $? -eq 0 ]]; then
                    echo "Checks went ok. Proceeding with extraction..." | tee -a $logloc/$@.log
                    echo "~~~~~~~~~~~~~~~~~ EXTRACTING ~~~~~~~~~~~~~~~~~" | tee -a $logloc/$@.log
                    7z x $@ 2>&1 >> $logloc/$@.log
                    if [[ $? -eq 0 ]]; then
                        echo "Files from $@ extracted successfuly" | tee -a $logloc/$@.log
                        exit 0
                    else
                        echo "Errors occured during extraction. Check log file for details. Aborting..."
                        exit 1; fi
                else
                    echo "File is corrupt. Aborting..."
                    exit 1; fi
            else
                echo "7z is not installed, please install it with your preferred package manager"
                exit 1; fi
            ;;

        * )
            echo "Unknown file format"
            exit 1
            ;;
    esac
}

info
xtract $@
