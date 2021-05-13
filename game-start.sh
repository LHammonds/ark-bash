#!/bin/bash
#############################################################
## Name          : game-start.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Start a specific game instance.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as the low-rights user.
## Run Frequency : As needed or when starting the server.
## Parameters    : Game Instance
## Exit Codes    :
##    0 = Success
##    1 = ERROR Missing parameter
##    2 = ERROR Invalid parameter
##    3 = ERROR Invalid array configuration
##    4 = ERROR Invalid user
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################
## Import standard variables and functions. ##
source /etc/gamectl.conf
LogFile="${LogDir}/game-start.log"

#######################################
##            FUNCTIONS              ##
#######################################
function f_showhelp()
{
  printf "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] Missing required parameter(s)\n" | tee -a ${LogFile}
  printf "Syntax : ${0} {InstanceName}\n"
  printf "Example: ${0} TheIsland\n"
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

## Check existence of required command-line parameters.
case "$1" in
  "")
    f_showhelp
    exit 1
    ;;
  --help|-h|-?)
    f_showhelp
    exit 1
    ;;
  *)
    GameInstance=$1
    ;;
esac

## Validate GameInstance ##

if [ ! -d "${GameRootDir}/${GameInstance}" ]; then
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] Invalid parameter. ${GameRootDir}/${GameInstance} does not exist." | tee -a ${LogFile}
  exit 2
fi

## Get rcon port number based on instance. ##
for intIndex in "${!arrInstanceName[@]}"
do
  if [ "${GameInstance}" == "${arrInstanceName[${intIndex}]}" ]; then
    MapName=${arrMapName[${intIndex}]}
    GamePort=${arrGamePort[${intIndex}]}
    QueryPort=${arrQueryPort[${intIndex}]}
    RCONPort=${arrRCONPort[${intIndex}]}
    break
  fi
done
if [ "${MapName}" == "" ]; then
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] MapName could not be matched with ${GameInstance}" | tee -a ${LogFile}
  exit 3
fi
if [ "${GamePort}" == "" ]; then
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] GamePort could not be matched with ${GameInstance}" | tee -a ${LogFile}
  exit 3
fi
if [ "${QueryPort}" == "" ]; then
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] QueryPort could not be matched with ${GameInstance}" | tee -a ${LogFile}
  exit 3
fi
if [ "${RCONPort}" == "" ]; then
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] RCONPort could not be matched with ${GameInstance}" | tee -a ${LogFile}
  exit 3
fi
if [ "${USER}" == "${GameService}" ]; then
  ## Already running as the low-rights user, start the instance. ##
  ${GameRootDir}/${GameInstance}/ShooterGame/Binaries/Linux/ShooterGameServer ${MapName}?listen?MultiHome=0.0.0.0?Port=${GamePort}?QueryPort=${QueryPort}?RCONPort=${RCONPort}?MaxPlayers=${MaxPlayers}?ServerAutoForceRespawnWildDinosInterval=86400?AllowCrateSpawnsOnTopOfStructures=True?GameModIds=${GameModIds} -clusterid=${ClusterID} ${OtherOptions}
elif [ "${USER}" == "root" ]; then
  ## Run command using low-rights user.
  su --command="${GameRootDir}/${GameInstance}/ShooterGame/Binaries/Linux/ShooterGameServer ${MapName}?listen?MultiHome=0.0.0.0?Port=${GamePort}?QueryPort=${QueryPort}?RCONPort=${RCONPort}?MaxPlayers=${MaxPlayers}?ServerAutoForceRespawnWildDinosInterval=86400?AllowCrateSpawnsOnTopOfStructures=True?GameModIds=${GameModIds} -clusterid=${ClusterID} ${OtherOptions}" ${GameService}
else
  ## Exit script with reason and error code. ##
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] ${GameInstance} service must be started by ${GameService}" | tee -a ${LogFile}
  exit 4
fi
exit 0
