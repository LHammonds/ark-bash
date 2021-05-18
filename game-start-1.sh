#!/bin/bash
#############################################################
## Name          : game-start-1.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Present menu to start one offline instance.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Must be run as root
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

function f_start()
{
  printf "\nsystemctl start ${1}\n"
  printf "\nNOTE: It may take a while before instance processes command.\n"
  systemctl start ${1}
}
#######################################
##               MAIN                ##
#######################################

## Loop through all defined game instances and build list of what is offline ##
arrList=()

for intIndex in "${!arrInstanceName[@]}"
do
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Check if instance is running ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "0" ]; then
      ## Instance is offline ##
      arrList+=(${arrInstanceName[${intIndex}]})
    fi
  fi
done

if [ ${#arrList[@]} -eq 0 ]; then
  ## If no instances are offline, the exit ##
  printf "[INFO] No instances are offline.\n"
else
  ## Loop thru offline instances, present options for user to select ##
  printf "Select which offline instance you want started:\n"
  for intIndex in "${!arrList[@]}"
  do
    printf " ${intIndex}) ${arrList[intIndex]}\n"
  done
  printf " x) Exit\n"
  read -n 1 -p "Your choice: " char_answer;
  ## This will break if there are more than 10 instances ##
  case ${char_answer} in
    0)   f_start ${arrList[0]};;
    1)   f_start ${arrList[1]};;
    2)   f_start ${arrList[2]};;
    3)   f_start ${arrList[3]};;
    4)   f_start ${arrList[4]};;
    5)   f_start ${arrList[5]};;
    6)   f_start ${arrList[6]};;
    7)   f_start ${arrList[7]};;
    8)   f_start ${arrList[8]};;
    9)   f_start ${arrList[9]};;
    x|X) printf "\nExit\n";;
    *)   printf "\nExit\n";;
  esac
fi

exit 0
