#!/bin/bash

Path=/home/user/pvc-fw/FWTools/Linux64
LogPath=/root/IFWI_flash_logs

function ifwi_check {

        $Path/GfxFwInfo|grep GFX
}

function ifwi_flash {

        $Path/GfxFwFPT -f $Path/PVC.DS.B.P.Si.2022.WW17.5_25MHz_Quad_DAMen_Common6_IFRv2212_PSCnull1_IFWI.bin -Device $1 -NOVERIFY -y
}

function first_check {

        if test -e $LogPath/ifwi_0 ; then
                        echo "  Already have log. Compare GfxFwInfo"

                else
                        count=0
                        error=0
                        echo "  This is first run."

                        mkdir $LogPath 2> /dev/null
                        ifwi_check > $LogPath/ifwi_0
                        ifwi_flash 3a:00:00 | tee $LogPath/${count}_GfxFwFPT_log_3a
                        ifwi_flash 9a:00:00 | tee $LogPath/${count}_GfxFwFPT_log_9a
                        cat $LogPath/${count}_GfxFwFPT_log_3a | tail -2 >> $LogPath/ifwi_0
                        cat $LogPath/${count}_GfxFwFPT_log_9a | tail -2 >> $LogPath/ifwi_0

                        log_str="$count | `date "+%m/%d %H:%M:%S"` | $error error "
                        echo "$log_str" >> /root/ifwi_check_log
                        echo $log_str

                        sleep 10

                        #init 6
                        init 0
                fi

}

function next_check {

               
        count=`tail -1 /root/ifwi_check_log | awk '{print$1}'`
        error=`tail -1 /root/ifwi_check_log | awk '{print$6}'`

        ifwi_check > $LogPath/ifwi_1
        ifwi_flash 3a:00:00 | tee $LogPath/${count}_GfxFwFPT_log_3a
        ifwi_flash 9a:00:00 | tee $LogPath/${count}_GfxFwFPT_log_9a
        cat $LogPath/${count}_GfxFwFPT_log_3a | tail -2 >> $LogPath/ifwi_1
        cat $LogPath/${count}_GfxFwFPT_log_9a | tail -2 >> $LogPath/ifwi_1
        ((count++)) 

        diff_ifwi="`diff $LogPath/ifwi_0 $LogPath/ifwi_1`"
        

        log_str="$count | `date "+%m/%d %H:%M:%S"` | $error error "
        echo "$log_str" >> /root/ifwi_check_log
        echo $log_str
        if [ "$diff_ifwi" != "" ]; then
                echo -e "$diff_ifwi \n\n" >> /root/ifwi_check_log
                echo $diff_ifwi
                ((error++))
        fi
}

#Load the driver
sudo modprobe i915

first_check
next_check

sleep 30

#init 6
init 0