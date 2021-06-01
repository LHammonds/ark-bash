#!/bin/bash
#############################################################
## Name          : game-sync-1.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Synchronize template to a game instance.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified install user.
##               : Instance needs to be stopped.
## Run Frequency : As needed or before starting a server.
## Parameters    : Game Instance (or none for interactive selection)
## Exit Codes    :
##    0 = Success
##    1 = ERROR Invalid user
##    2 = ERROR Cannot sync online instance
##    3 = ERROR Invalid parameter
##    4 = ERROR No offline instances
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

ErrorCount=0
LogFile="${LogDir}/game-sync-server.log"

#######################################
##            FUNCTIONS              ##
#######################################

function f_sync()
{
  StartTime="$(date +%s)"
  printf "`date +%Y-%m-%d_%H:%M:%S` - Sync ${1} started.\n" | tee -a ${LogFile}
  if [ "${USER}" = "root" ]; then
    ## Switch to the install user and update the instance ##
    f_verbose "su --command='rsync -a --exclude 'ShooterGame/Saved' --exclude 'steamapps/workshop' ${TemplateDir}/ ${GameRootDir}/${1}' ${GameUser}"
    su --command="rsync -a --exclude 'ShooterGame/Saved' --exclude 'steamapps/workshop' ${TemplateDir}/ ${GameRootDir}/${1}" ${GameUser}
  else
    ## Already running as install user, update the instance ##
    f_verbose "rsync -a --exclude 'ShooterGame/Saved' --exclude 'steamapps/workshop' ${TemplateDir}/ ${GameRootDir}/${1}"
    rsync -a --exclude 'ShooterGame/Saved' --exclude 'steamapps/workshop' ${TemplateDir}/ ${GameRootDir}/${1}
  fi
  ReturnCode=$?
  if [ "${ReturnCode}" != "0" ]; then
    printf "[ERROR] rsync ReturnCode=${ReturnCode}\n" | tee -a ${LogFile}
  fi
  ## Calculate total runtime ##
  FinishTime="$(date +%s)"
  ElapsedTime="$(expr ${FinishTime} - ${StartTime})"
  Hours=$((${ElapsedTime} / 3600))
  ElapsedTime=$((${ElapsedTime} - ${Hours} * 3600))
  Minutes=$((${ElapsedTime} / 60))
  Seconds=$((${ElapsedTime} - ${Minutes} * 60))
  printf "[INFO] Total runtime: ${Hours} hour(s) ${Minutes} minute(s) ${Seconds} second(s)\n" | tee -a ${LogFile}
  printf "`date +%Y-%m-%d_%H:%M:%S` - Sync ${1} completed.\n" | tee -a ${LogFile}
}

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

GameInstance=""
## Check command-line parameter for specified instance ##
case "$1" in
  "") printf "[INFO] Game instance not specified as parameter. Going into pick list mode.\n";;
  *)  GameInstance=$1;;
esac

if [ "${GameInstance}" != "" ]; then
  ## Validate GameInstance ##
  if [ -f "${GameRootDir}/${GameInstance}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Verify instance is offline ##
    ${ScriptDir}/game-online.sh ${GameInstance} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "0" ]; then
      ## Instance is offline, use parameter ##
      f_sync ${GameInstance}
      exit 0
    else
      printf "[ERROR] Cannot sync ${GameInstance} while online.\n"
      exit 2
    fi
  else
    printf "[ERROR] Invalid instance.\n"
    exit 3
  fi
fi

## Loop through all defined game instances and build list of what is online ##
arrList=()

for intIndex in "${!arrInstanceName[@]}"
do
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Verify instance is offline ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "0" ]; then
      ## Instance is inactive ##
      arrList+=(${arrInstanceName[${intIndex}]})
    fi
  fi
done

if [ ${#arrList[@]} -eq 0 ]; then
  ## If no instances are offline, the exit ##
  printf "[INFO] No instances are offline. Cannot continue sync.\n"
  exit 4
else
  ## Loop thru offline instances, present options for user to select ##
  printf "Select which offline instance you want synchronized from the template:\n"
  for intIndex in "${!arrList[@]}"
  do
    printf " ${intIndex}) ${arrList[intIndex]}\n"
  done
  printf " x) Exit\n"
  read -n 1 -p "Your choice: " char_answer;
  printf "\n"
  ## This will break if there are more than 10 instances ##
  case ${char_answer} in
    0)   f_sync ${arrList[0]};;
    1)   f_sync ${arrList[1]};;
    2)   f_sync ${arrList[2]};;
    3)   f_sync ${arrList[3]};;
    4)   f_sync ${arrList[4]};;
    5)   f_sync ${arrList[5]};;
    6)   f_sync ${arrList[6]};;
    7)   f_sync ${arrList[7]};;
    8)   f_sync ${arrList[8]};;
    9)   f_sync ${arrList[9]};;
    x|X) printf "Exit\n";;
    *)   printf "Exit\n";;
  esac
fi
exit 0
