#!/bin/bash

count=0
error=0

function info_check {
        /root/system_check.sh

}


function first_check {

        if test -e /root/lspci_0 ; then
                        echo "  Already have log. Compare pci device."
                else
                        echo "  This is first run."
                        info_check > /root/lspci_0
                        cat /root/lspci_0
                fi

}


function next_check {

        info_check > /root/lspci_1
        diff_lspci="`diff /root/lspci_0 /root/lspci_1`"
        ((count++))

        log_str="$count | `date "+%m/%d %H:%M:%S"` | $error error "
        echo "$log_str" >> /root/regular_lspci_check_log
        if [ "$diff_lspci" != "" ]; then
                echo -e "$diff_lspci \n\n" >> /root/regular_lspci_check_log
                ((error++))
        fi
}




if test -e /root/lspci_1 ; then
        rm /root/lspci_0 /root/lspci_1 /root/regular_lspci_check_log
fi

first_check

while :
do

        sleep 5m

        next_check

done
