#!/bin/bash

# Setting Variables
CPU_RESERVE_PATH=/nethome/prj/openbus/work/scs_healing/injectors/CPU_RSV_2009_02_19
ED_PATH=/nethome/di/econdori

#
# Create Client with reserve
# Template:  ./client machine:port    period<ms> slice<ms> conserving<0|1> command <args,...>
# Default :  ./client localhost:8010  1000       500       0               Cpustress 
# 

CLIENT_SLICE=$1

if [ -z ${CLIENT_SLICE} ]; then
    CLIENT_SLICE=500
    echo "No slice was especified, using default slice:" ${CLIENT_SLICE}
fi

CLIENT_CPU_INTENSIVE=Cpustress
CLIENT_PERIOD=1000
CLIENT_CONSERVING=0
CLIENT_TMP_FILE=${ED_PATH}/client.out

##############
# Stress CPU #
##############

#
# Option 1: ./client
# Summary : Create and kill many clients "Cpustress"
# Version : 0.1
# 
nohup $CPU_RESERVE_PATH/client localhost:8010 ${CLIENT_PERIOD} ${CLIENT_SLICE} ${CLIENT_CONSERVING} \
java -cp . ${CLIENT_CPU_INTENSIVE} 1>/$ED_PATH/client.out 2>/$ED_PATH/client.err &
sleep 2s
visual2_pid=`cat $CLIENT_TMP_FILE | grep -o "[1-9][0-9]\+"`
echo $visual2_pid > /$ED_PATH/pidclient.txt

