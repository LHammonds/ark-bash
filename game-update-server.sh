#!/bin/bash
#############################################################
## Name          : game-update-server.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Update the server template from Steam.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified install user.
## Run Frequency : Whenever needed.  Template should never be running.
## Parameters    : N/A
## Exit Codes    :
##    0 = Success
##    1 = Invalid user
##    ? = All other error codes are the result of steamcmd exit code.
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

LogFile="${LogDir}/game-update-server.log"
SteamOut="${TempDir}/steam.out"
NoUpdate="already up to date"
UpgradeSuccess="fully installed"

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameUser}" ]; then
  printf "[ERROR] This script must be run as root or ${GameUser}.\n"
  exit 1
fi

#######################################
##              MAIN                 ##
#######################################

if [ -f ${SteamOut} ]; then
  ## Remove the temp file before we use it ##
  rm ${SteamOut}
fi
printf "`date +%Y-%m-%d_%H:%M:%S` - Started template update.\n" | tee -a ${LogFile}
if [ "${USER}" == "root" ]; then
  ## Switch to the install user and update the instance ##
  f_verbose "su --command='${SteamCMD} +login anonymous +force_install_dir ${TemplateDir} +app_update ${ServerID} +quit > ${SteamOut}' ${GameUser}"
  su --command="${SteamCMD} +login anonymous +force_install_dir ${TemplateDir} +app_update ${ServerID} +quit > ${SteamOut}" ${GameUser}
  ReturnCode=$?
elif [ "${USER}" == "${GameUser}" ]; then
  ## Already running as the install user, update the instance ##
  f_verbose "${SteamCMD} +login anonymous +force_install_dir ${TemplateDir} +app_update ${ServerID} +quit > ${SteamOut}"
  ${SteamCMD} +login anonymous +force_install_dir ${TemplateDir} +app_update ${ServerID} +quit > ${SteamOut}
  ReturnCode=$?
fi
f_verbose "[INFO] SteamCMD ReturnCode=${ReturnCode}"
if grep -Fq "${NoUpdate}" ${SteamOut}; then
  ## No update found ##
  printf "[INFO] No update found.\n" | tee -a ${LogFile}
else
  if grep -Fq "${UpgradeSuccess}" ${SteamOut}; then
    ## Upgrade peformed and was successful ##
    printf "[INFO] Update performed and was successful.\n" | tee -a ${LogFile}
  else
    ## Other issue (could be error, lack of space, timeout, etc.) ##
    printf "[UNKNOWN] Unknown result...need exact wording.\n" | tee -a ${LogFile}
    printf "[SAVE] Output text saved to ${GameRootDir}/bak/`date +%Y-%m-%d_%H-%M-%S`-steam.out\n" | tee -a ${LogFile}
    cp ${SteamOut} ${BackupDir}/`date +%Y-%m-%d_%H-%M-%S`-steam.out
  fi
fi
printf "`date +%Y-%m-%d_%H:%M:%S` - Completed template update.\n" | tee -a ${LogFile}
exit ${ReturnCode}
