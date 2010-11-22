#!/bin/bash

# Setting Variables
CPU_RESERVE_PATH=/nethome/prj/openbus/work/scs_healing/injectors/CPU_RSV_2009_02_19
ED_PATH=/nethome/di/econdori

#
# SERVER (static configuration)
# ./server <port> <#processors-binary> <processing-limit-noVM>
# ./server 8010   1                     1
#
nohup sudo -S $CPU_RESERVE_PATH/server 8010 1 1 < $CPU_RESERVE_PATH/se2.txt 1>/$ED_PATH/server.out 2>/$ED_PATH/server.err &
pid=$!
echo $pid >/$ED_PATH/pidserver.txt
sleep 2

