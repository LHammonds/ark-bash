#!/bin/bash
#############################################################
## Name          : game-stop-all.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Stop all game instances.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified low-rights user.
## Run Frequency : As needed such as before updates or rebooting server.
## Parameters    : None
## Exit Codes    :
##    0 = Success, all instances are offline
##    1 = Failure, one or more instances are still running.
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

#######################################
##            FUNCTIONS              ##
#######################################

function f_stop()
{
  nohup ${ScriptDir}/game-stop.sh ${1} > /dev/null 2>&1 &
} ## f_stop() ##

#######################################
##               MAIN                ##
#######################################

## Loop through all defined game instances ##
for intIndex in "${!arrInstanceName[@]}"
do
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Only shutdown instance if running ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "1" ]; then
      ## Instance is active ##
      printf "[INFO] Stopping ${arrInstanceName[${intIndex}]}\n"
      f_stop ${arrInstanceName[${intIndex}]}
    fi
  fi
done

ExitStatus=1
intIndex=1
intMax=20
while [[ ${intIndex} -lt ${intMax} ]]
do
  ${ScriptDir}/game-listall.sh
  ReturnCode=$?
  if [ "${ReturnCode}" == "0" ]; then
    ## All instances are down ##
    printf "[INFO] All instances are offline\n"
    ExitStatus=0
    break
  else
    if [ "${ReturnCode}" == 1 ]; then
      printf "[INFO] ${ReturnCode} instance is online. Continuing to wait...\n"
    else
      printf "[INFO] ${ReturnCode} instances are online. Continuing to wait...\n"
    fi
  fi
  printf "[INFO] Pause ${intIndex}/${intMax}.\n"
  sleep 10
  ((intIndex++))
done
exit ${ExitStatus}
