#!/bin/bash
#############################################################
## Name          : game-stop.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Stop a specific game instance.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Must be run with the specified low-rights user.
## Run Frequency : As needed or when shutting down server.
## Parameters    : Game Instance
## Exit Codes    :
##    0 = Success
##    2 = ERROR Missing parameter
##    3 = ERROR Invalid parameter
##    4 = ERROR Unexpected parameter
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf
LogFile="${LogDir}/game-stop.log"

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
if [ ! -d "${GameRootDir}/${GameInstance}" ]; then
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] Invalid parameter. ${GameRootDir}/${GameInstance} does not exist." | tee -a ${LogFile}
  exit 3
fi

#######################################
##               MAIN                ##
#######################################
if [ "${USER}" == "${GameService}" ]; then
  ${ScriptDir}/game-cmd.sh ${GameInstance} ServerChat "Stop server command has been issued."
  ${ScriptDir}/game-cmd.sh ${GameInstance} ServerChat "Saving world..."
  ${ScriptDir}/game-cmd.sh ${GameInstance} SaveWorld
  ${ScriptDir}/game-cmd.sh ${GameInstance} ServerChat "World stopped.  Goodbye!"
  sleep 2
  ${ScriptDir}/game-cmd.sh ${GameInstance} DoExit
  echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] ${GameInstance} stopped." | tee -a ${LogFile}
elif [ "${USER}" == "root" ]; then
  su --command="${ScriptDir}/game-cmd.sh ${GameInstance} ServerChat \"Stop server command has been issued.\"" ${GameService}
  su --command="${ScriptDir}/game-cmd.sh ${GameInstance} ServerChat \"Saving world...\"" ${GameService}
  su --command="${ScriptDir}/game-cmd.sh ${GameInstance} SaveWorld" ${GameService}
  su --command="${ScriptDir}/game-cmd.sh ${GameInstance} ServerChat \"World stopped.  Goodbye!\"" ${GameService}
  sleep 2
  su --command="${ScriptDir}/game-cmd.sh ${GameInstance} DoExit" ${GameService}
  echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] ${GameInstance} stopped." | tee -a ${LogFile}
else
  ## Exit script with reason and error code. ##
  echo "`date +%Y-%m-%d_%H:%M:%S` - [ERROR] ${GameInstance} Service must be stopped by ${GameService}" | tee -a ${LogFile}
  exit 4
fi
exit 0
