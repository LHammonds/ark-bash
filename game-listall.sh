#!/bin/bash
#############################################################
## Name          : game-listall.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : List all game instances and their status.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified low-rights user.
## Run Frequency : As needed.
## Parameters    : None
## Exit Codes    : Number of online instances.
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

#######################################
##           MAIN PROGRAM            ##
#######################################

intTotalOn=0
IntTotalOff=0
printf "Online Status\n"
printf "=============\n"
## Get query port used based on instance name. ##
for intIndex in "${!arrInstanceName[@]}"
do
  ## Check if folder for game instance exists. ##
  if [ -d "${GameRootDir}/${arrInstanceName[${intIndex}]}" ]; then
    ## Output status of instance. ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]}
    ReturnCode=$?
    if [ "${ReturnCode}" = "0" ]; then
      intTotalOn=$((${intTotalOn} + 1))
    elif [ "${ReturnCode}" = "1" ]; then
      intTotalOff=$((${intTotalOff} + 1))
    fi
  fi
done
printf "Total online: ${intTotalOn}\n"
printf "Total offline: ${intTotalOff}\n"
exit ${intTotalOn}
