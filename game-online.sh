#!/bin/bash
#############################################################
## Name          : game-online.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Check if game instance is listening to its port.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified low-rights user.
## Run Frequency : As needed.
## Parameters    : Game Instance
## Exit Codes    :
##    0 = Success/Offline
##    1 = Success/Online
##    2 = Non-successful exit
##    NOTE: Exit code is used by other scripts to count online instances.
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

function f_showhelp()
{
  printf "[ERROR] Missing required parameter(s)\n"
  printf "Syntax : ${0} {InstanceName}\n"
  printf "Example: ${0} TheIsland\n\n"
  printf "List of existing game instances\n"
  printf "===============================\n"
  for intIndex in "${!arrInstanceName[@]}"
  do
    ## Verify instance is installed ##
    if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
      printf "${arrInstanceName[${intIndex}]}\n"
    fi
  done
}

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access. ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameService}" ]; then
  printf "[ERROR] This script must be run as root or ${GameService}.\n"
  exit 2
fi

## Check existance of required command-line parameters. ##
case "$1" in
  "")
    f_showhelp
    exit 2
    ;;
  --help|-h|-?)
    f_showhelp
    exit 2
    ;;
  *)
    GameInstance=$1
    ;;
esac

## Validate GameInstance ##
if [ ! -f "${GameRootDir}/${GameInstance}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
  printf "[ERROR] Invalid parameter. ${GameRootDir}/${GameInstance} is not a valid instance.\n"
  exit 2
fi

#######################################
##           MAIN PROGRAM            ##
#######################################

## Get query port used based on instance name. ##
for intIndex in "${!arrInstanceName[@]}"
do
  if [ "${GameInstance}" == "${arrInstanceName[${intIndex}]}" ]; then
    QueryPort=${arrQueryPort[${intIndex}]}
    break
  fi
done
if [ "${QueryPort}" == "" ]; then
  printf "[ERROR] QueryPort could not be matched with ${GameInstance}\n"
  exit 2
fi

/usr/bin/lsof -i:${QueryPort} 1>/dev/null 2>&1
if [ "$?" == "0" ]; then
  echo -e "[${GREEN}Online${COLORRESET}]  ${GameInstance}:${QueryPort}"
  ReturnCode=1
else
  echo -e "[${RED}Offline${COLORRESET}] ${GameInstance}:${QueryPort}"
  ReturnCode=0
fi
exit ${ReturnCode}
