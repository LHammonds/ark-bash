#!/bin/bash
#############################################################
## Name          : game-start-all.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Start all game instances.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root
## Run Frequency : As needed or when starting all servers.
## Parameters    : None
## Exit Codes    : None
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

#######################################
##               MAIN                ##
#######################################

## Loop through all defined game instances ##
for intIndex in "${!arrInstanceName[@]}"
do
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Check if instance is running ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "0" ]; then
      ## Instance is offline ##
      echo "[INFO] Starting ${arrInstanceName[${intIndex}]}"
      systemctl start ${arrInstanceName[${intIndex}]}
    fi
  fi
done
exit 0
