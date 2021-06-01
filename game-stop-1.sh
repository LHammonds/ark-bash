#!/bin/bash
#############################################################
## Name          : game-stop-1.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Present menu to stop one online instance.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified low-rights user.
## Run Frequency : As needed
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
##            FUNCTIONS              ##
#######################################

function f_stop()
{
  nohup ${ScriptDir}/game-stop.sh ${1} > /dev/null 2>&1 &
} ## f_stop() ##

#######################################
##               MAIN                ##
#######################################

## Loop through all defined game instances and build list of what is online ##
arrList=()

for intIndex in "${!arrInstanceName[@]}"
do
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Check if instance is running ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "1" ]; then
      ## Instance is active ##
      arrList+=(${arrInstanceName[${intIndex}]})
    fi
  fi
done

if [ ${#arrList[@]} -eq 0 ]; then
  ## If no instances are online, the exit ##
  printf "[INFO] No instances are online.\n"
else
  ## Loop thru online instances, present options for user to select ##
  printf "Select which online instance you want stopped:\n"
  for intIndex in "${!arrList[@]}"
  do
    printf " ${intIndex}) ${arrList[intIndex]}\n"
  done
  printf " x) Exit\n"
  read -n 1 -p "Your choice: " char_answer;
  printf "\n"
  ## This will break if there are more than 10 instances ##
  case ${char_answer} in
    0)   f_stop ${arrList[0]};;
    1)   f_stop ${arrList[1]};;
    2)   f_stop ${arrList[2]};;
    3)   f_stop ${arrList[3]};;
    4)   f_stop ${arrList[4]};;
    5)   f_stop ${arrList[5]};;
    6)   f_stop ${arrList[6]};;
    7)   f_stop ${arrList[7]};;
    8)   f_stop ${arrList[8]};;
    9)   f_stop ${arrList[9]};;
    x|X) printf "\nExit\n";;
    *)   printf "\nExit\n";;
  esac
fi
printf "\nNOTE: It takes time for an instance to process a stop command.\n"
exit 0
