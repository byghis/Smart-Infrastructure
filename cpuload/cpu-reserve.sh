#!/bin/bash

#
# Objective: Manage the CPULoad in many ways
# Version  : 0.2
# Author:    Edward
#

#
# Loading the library log4sh
# More information: 
#

# Load log4sh
if [ -r log4sh ]; then
   LOG4SH_CONFIGURATION='none' . ./log4sh
else
   echo "ERROR: could not load (log4sh)" >&2
   exit 1
fi

# Change the default message level from ERROR to INFO
logger_setLevel INFO

#
# Getting OS-Info
#
OS=Linux
CPU=1
USER=edward
CPUMAX=100
CPU_SCALE=$[${CPU}*${CPUMAX}]

#
# Setting the function
#
TYPE_FUNCTION={'sine', 'square'}

#
# Setting function options(sine)
# Define how unit times take one wave
#
WAVE_TIME=10

# Amplitude 
PEAK_TIME=$[${WAVE_TIME}/2]
logger_info "PEAK_TIME:" ${PEAK_TIME}

# Angular Frecuency(define how many oscillations occur in unit time, 
# SINE_FRECUENCY=

# CPU Load increment depends 
CPULOAD_INCREMENT_TIME=$[${CPU_SCALE}/${PEAK_TIME}]
logger_info "CPULOAD_INCREMENT_TIME:" ${CPULOAD_INCREMENT_TIME}

#
# Generate time interval dataset. 
# Means the CPULOAD variations according to wave time.
WAVE_CPULOAD=(
`for(( i=0;i<=${PEAK_TIME};i++ )); do
	echo $[${CPULOAD_INCREMENT_TIME}*${i}]
done`
`for(( i=1;i<=${PEAK_TIME};i++)); do
        echo $[${CPU_SCALE}-${CPULOAD_INCREMENT_TIME}*${i}]
done`
)

# Number of elements where the cpuload will happen
LENGTH_WAVE_CPULOAD=${#WAVE_CPULOAD[*]}
logger_info "LENGTH_WAVE_CPULOAD:" ${LENGTH_WAVE_CPULOAD}

# Iterate the SET_WAVE_CPULOAD
logger_info "PRINTING THE SET WAVE CPULOAD:"
for(( i=0;i<${LENGTH_WAVE_CPULOAD};i++ )); do
	logger_info ${WAVE_CPULOAD[${i}]}
done

#
# Add new functions here:
#

#
# Setting the TIME
#

# NOTE
# The basic unit time is seconds using the function sleep available in
# linux, for more precision such as milliseconds or microseconds will be
# necessary use utility function in perl or c. If the linux os is a redhat
# distribution is possible use usleep(microseconds) function.
UNIT_TIME="seconds"

#
# Run $NUM_TASK process
#
function run_process {

    NUM_TASK=$1
    logger_info "Running " ${NUM_TASK} " process"
    ./linkstress -c ${NUM_TASK} & pid=$!

}


#
# Return $NUM_PROCESS process
#
array_process_kill=""

function get_process() {
    local array=()
    NUM_PROCESS=$1
    logger_info "Getting Process"
    #array=( 1 2 3 4 5)
    array=`ps aux|grep linkstress|awk '{print $2}'`
    array_process_kill=(${array[@]})
}

#
# Kill ${NUM_PROCESS} process
#
function kill_process {

    NUM_PROCESS=$1
    logger_info "Kill Process"	
    get_process ${NUM_PROCESS}
    process_kill=(${array_process_kill[*]})

    if [ ${process_kill} ]; then
	length_process_kill=$[${#process_kill[*]}-1]
	logger_info "Length of process to kill: " ${length_process_kill}
	if [ ${length_process_kill} -ge ${NUM_PROCESS} ]; then
	    logger_info "Killing process contract will be complete"
	    for (( j=0 ; j <= ${NUM_PROCESS} ; j++ )); do
		logger_info "Killing process " ${j} " :" ${process_kill[${j}]}
		kill ${process_kill[${j}]}
	    done
	else
	    logger_info "Only, the next process will be killed " ${length_process_kill}
	    for (( j=0 ; j <= ${length_process_kill} ; j++ )); do
		logger_info "Killing process " ${j} " :" ${process_kill[${j}]}
		kill ${process_kill[${j}]}
	    done
	fi
    fi

}

#
# Function load_cpu(%n)
# Load the cpu to %n, for now only support 1 Core CPU 
# Using Strees Tool
# Reference: http://weather.ou.edu/~apw/projects/stress/
#

# Function sine
WAVE_UP=0
function load_cpu() {

    VALUE_CPULOAD=$1
    NUM_PROCESS=$2
    logger_info "Trying make load_cpu:" ${VALUE_CPULOAD}
    logger_info "The number of tasks for iterate is:" ${NUM_PROCESS}

    if [ $WAVE_UP -eq 0 ]; then
	run_process  ${NUM_PROCESS}
    else
	kill_process ${NUM_PROCESS}
    fi

    if [ ${VALUE_CPULOAD} -eq 100 ]; then
	logger_info "Maxime WAPE UP was reached"
	WAVE_UP=1
    fi
    logger_info "Value WAVE_UP: " $WAVE_UP
}

# Not implemented yet (see run-cpustress-client.sh)
# function load_cpureserve_client {}

# Function cpureserve_adapt
function cpureserve_adapt {

    VALUE_CPULOAD=$1 #convert to slice time
    NUM_PROCESS=$2   #probably no used

    CLIENT_SLICE=$[${VALUE_CPULOAD}*10]
    logger_info "Trying make load_cpu:" ${VALUE_CPULOAD}
    logger_info "The number of tasks for iterate is:" ${NUM_PROCESS}
    logger_info "Adapting to:" ${CLIENT_SLICE}

    # Adapt
    # ./adapt machine:port period<ms> slice<ms> conserving<0|1> <pid>
    CPU_RESERVE_HOME=
    SERVER_PORT=8010
    ADAPT_PERIOD=1000
    ADAPT_SLICE=${CLIENT_SLICE}
    ADAPT_CONSERVING=0

    logger_info "Adapting Cpustress to consumer only: " ${ADAPT_SLICE} " % process"
    ${CPU_RESERVE_HOME}/adapt localhost:${SERVER_PORT} \ 
    ${ADAPT_PERIOD} ${ADAPT_SLICE} ${ADAPT_CONSERVING} ${VIEWER_TWO_PID}

}

#
# Using monitor_loadcpu
#
function monitor_loadcpu {
    TIME=$1
    sleep ${TIME}
    TOTAL_TIME=$2
    #INDEX=$3
    CPULOAD_AVG=`cat /proc/loadavg|awk '{print $1}'`
    echo "${INDEX} ${TOTAL_TIME} ${CPULOAD_AVG}" >> /tmp/cpuloadavg.dat

}

#
# Function Sine
# Please set:
# PROCESS: number of process to stress cpu (more process, more quickly stress cpu) 
# WAVE_CPULOAD: set of points on line time where the cpu is load
# TIME_MONITORING: by default 60s 
# Result : plot /tmp/cpuloadavg.dat (gnuplot> plot 'cpuloadavg.dat')
#

CPULOAD_TYPE="cpureserve"
num_wave=1
#function load_cpu_sin {

#while true
#do

	# Start CPUReserve(server) (load_cpureserve_server)
	if [ "${CPULOAD_TYPE}"="cpureserve" ]; then
		logger_info "Using CPUReserver to give cpuload"
		logger_info "Starting a ./server(see run-cpureserve-server.sh):"
		./run-server.sh
		logger_info "The CPUReserve (server) was executed"
	fi

	# Start "one client" cpustress. Next adapt in loop (load_cpureserve_client)
	logger_info "Starting Cpustress:"
	./run-cpustress-client.sh 0

	logger_info "---> Starting a new wave: ${num_wave}"
	PROCESS=10
	TIME_MONITORING=60
	TOTAL_TIME_MONITORING=0
	for(( i=1 ; i<${LENGTH_WAVE_CPULOAD} ; i++ )); do
		logger_info "Calling function load_cpu(" ${WAVE_CPULOAD[${i}]} " )"
		#load_cpu ${WAVE_CPULOAD[${i}]} ${PROCESS}		
		cpureserve_adapt ${WAVE_CPULOAD[${i}]} ${PROCESS}
		monitor_loadcpu ${TIME_MONITORING} ${TOTAL_TIME_MONITORING} #${i}
		let TOTAL_TIME_MONITORING+=${TIME_MONITORING}
	done
	let num_wave+=1
#done

#}

# 
# Main Code
#




#
# Statistics
#

#################
# DOCUMENTATION #
#################

#
# Main Algorithm Steps
# 
# 1. Setting the variables(for the moment only support "seconds" and "sine" function)
# 2. WAVE_CPULOAD contains the cpu-load variations calculated from the WAVE_TIME
# 3. Do a loop infinite, the idea is execute infinite loop waves ( one for loop will be a wave)
# 4. Inside the loop for: sleep 1 and load cpu 
# 5. End

# Example (no tested)
# 
# wave_time=10 #means the time for complete the wave is 10 seconds
# wave_cpuload=(0 20 40 60 80 100 80 60 40 20 0) # calculate the wave cpuload distributed along the wave
# while true
# do
# 	for(( i=0 ; length(wave_cpuload) ; i++)); do 
# 		sleep 1 # setted for sleep 1 second
# 		load_cpu(array[i])
# 	done
# done

#
# NOTE about the time
#
# If for example the wave is 10T, and T=seconds means that the wave has
# 10 seconds for complete the wave and the cpu_load will be [0 20 40 60 80 100 80 60 40 20 0]
# in the case that more intensive cpu_load is required then 

#
# Ideas (automating code)
#

# script.sh -function name -twave NN -utime seconds -dataset [4-#core*100*NN]
# script.sh -function sine -twave 20 -utime seconds -dataset [4-200]
# Suponiendo 1 core el intervalo puede ser desde 4 segundos a 200 segundos de la ola: [4 - 200]



