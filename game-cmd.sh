#!/bin/bash
#############################################################
## Name          : game-cmd.sh
## Version       : 1.1
## Date          : 2022-06-22
## Author        : LHammonds
## Purpose       : Send a command to a specific game instance.
## Compatibility : Verified on Ubuntu Server 22.04 LTS
## Requirements  : rcon - https://github.com/LHammonds/c/blob/main/rcon.c
## Run Frequency : As needed for sending console commands to server.
## Parameters    : #1 - Game Instance
##               : #2 - Command to send to console
## Exit Codes    :
##    0 = Success
##    1 = Invalid array configuration
##    2 = Missing parameter #1
##    3 = Missing parameter #2
##    4 = Invalid parameter #1
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
## 2022-06-22 1.1 LTH Replaced echo with printf command.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

#######################################
##            FUNCTIONS              ##
#######################################

function f_showhelp()
{
  printf "[ERROR] Missing required parameter(s)\n"
  printf "Syntax  : ${0} {InstanceName} {Command}\n"
  printf "Example1: ${0} TheIsland DoExit\n"
  printf "Example2: ${0} Ragnarok \"Broadcast Hello World!\"\n\n"
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

function f_runcmd()
{
  ## Get rcon port number based on instance. ##
  for intIndex in "${!arrInstanceName[@]}"
  do
    if [ "${GameInstance}" == "${arrInstanceName[${intIndex}]}" ]; then
      RCONPort=${arrRCONPort[${intIndex}]}
      break
    fi
  done
  if [ "${RCONPort}" == "" ]; then
    printf "[ERROR] RCONPort could not be matched with ${GameInstance}\n"
    return 1
  fi
  ${ScriptDir}/rcon -f ${RCONFile} -p ${RCONPort} ${cmd}
  return 0
}

#######################################
##          PREREQUISITES            ##
#######################################

## Check existance of required command-line parameters.
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

case "$2" in
  "")
    f_showhelp
    exit 3
    ;;
  *)
    cmd="$2 $3 $4 $5 $6 $7 $8 $9"
    ;;
esac

## Validate GameInstance ##

if [ ! -f "${GameRootDir}/${GameInstance}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
  printf "ERROR: Invalid parameter. ${GameRootDir}/${GameInstance}/ShooterGame/Binaries/Linux/ShooterGameServer does not exist.\n"
  exit 4
fi

#######################################
##               MAIN                ##
#######################################

f_runcmd ${GameInstance} ${cmd}
exit $?
