#!/bin/bash
#############################################################
## Name          : game-restore-map.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Restore from prior backup.
## Compatibility : Ubuntu Server 20.04
## Parameters    : None
## Requirements  : Run as root
## Run Frequency : Designed to run on demand.
## Exit Codes    :
##    0 = Success or user abort
##    1 = ERROR Invalid user
##    2 = Archive folder does not exist
##    3 = Archive extraction failure
##    4 = Missing map file after extraction
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

LogFile="${LogDir}/game-restore-map.log"
InstanceName=""

#######################################
##            FUNCTIONS              ##
#######################################

function f_abort()
{
  printf "`date +%Y-%m-%d\ %H:%M:%S` [ABORT] ErrorCode=${1}\n" >> ${LogFile}
  exit ${1}
} ## f_abort()

function f_checkspace()
{
  printf "Checkspace function called but nothing to do.\n"
} ## f_checkspace()

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access ##
if [ "${USER}" != "root" ]; then
  printf "[ERROR] This script must be run as root, EC=1\n"
  exit 1
fi

## Check to make sure the archive folder exists ##
if [ ! -d "${BackupDir}" ]; then
  ## Archive folder does not exist ##
  printf "[ERROR] The archive folder does not exist! ${BackupDir}, EC=2\n"
  exit 2
fi

#######################################
##           MAIN PROGRAM            ##
#######################################

clear
printf "           R E S T O R E\n"
printf "           -------------\n"
printf "            Step 1 of 4\n\n"
## Build a list of installed and offline instances ##
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
  printf "Select which offline instance you want restored:\n"
  for intIndex in "${!arrList[@]}"
  do
    printf " ${intIndex}) ${arrList[intIndex]}\n"
  done
  printf " x) Exit\n"
  read -n 1 -p "Your choice: " char_answer;
  ## This will break if there are more than 10 instances ##
  case ${char_answer} in
    0)   InstanceName=${arrList[0]};;
    1)   InstanceName=${arrList[1]};;
    2)   InstanceName=${arrList[2]};;
    3)   InstanceName=${arrList[3]};;
    4)   InstanceName=${arrList[4]};;
    5)   InstanceName=${arrList[5]};;
    6)   InstanceName=${arrList[6]};;
    7)   InstanceName=${arrList[7]};;
    8)   InstanceName=${arrList[8]};;
    9)   InstanceName=${arrList[9]};;
    *)   printf "\n"
         f_abort 0;;
  esac
fi
if [ "${InstanceName}" = "" ]; then
  printf "\n"
  f_abort 0
fi

clear
printf "           R E S T O R E\n"
printf "           -------------\n"
printf "            Step 2 of 4\n\n"
printf "You have chosen to restore ${InstanceName}\n"

## Define user prompt using the special PS3 variable ##
PS3="Type number for the desired archive or 'q' to quit: "

## Get sorted list of all archives (newest at the bottom) ##
FileList=$(find ${BackupDir}/map/*${InstanceName}* -maxdepth 1 -type f | sort -f)

## Prompt user to select a file to use. ##
## NOTE: If it is a long list, user can scroll ##
##       up if using PuTTY to see older files. ##
select GetFile in ${FileList}; do
  if [ "${GetFile}" != "" ]; then
    Filename=${GetFile}
  fi
  break
done
if [ "${Filename}" = "" ]; then
  ## User opted to quit ##
  f_abort 0
fi
clear
printf "           R E S T O R E\n"
printf "           -------------\n"
printf "            Step 3 of 4\n\n"
printf "Selected file:\n${Filename}\n"
read -p "Purge current files before restore (y/n)? "
if [ "${REPLY}" = "y" ]; then
  DeleteBeforeRestore="y"
else
  DeleteBeforeRestore="n"
fi
clear
printf "    R E S T O R E   S U M M A R Y\n"
printf "    -----------------------------\n"
printf "            Step 4 of 4\n\n"
printf "Instance to restore: ${InstanceName}\n"
printf "Archive to restore: ${Filename}\n"
printf "Delete before restore? ${DeleteBeforeRestore}\n\n"
read -p "Are you absolutely sure you wish to restore (y/n)? "
if [ "${REPLY}" != "y" ]; then
  printf "Restore aborted.\n"
  f_abort 0
fi
printf "`date +%Y-%m-%d\ %H:%M:%S` - Restore started.\n" | tee -a ${LogFile}
printf "Instance: ${InstanceName}\n" >> ${LogFile}
printf "Archive: ${Filename}\n" >> ${LogFile}
printf "Delete before restore: ${DeleteBeforeRestore}\n" >> ${LogFile}
if [ "${DeleteBeforeRestore}" = "y" ]; then
  rm ${GameRootDir}/${InstanceName}/ShooterGame/Saved/SavedArks/*.ark
  rm ${GameRootDir}/${InstanceName}/ShooterGame/Saved/SavedArks/*.arktribe
  rm ${GameRootDir}/${InstanceName}/ShooterGame/Saved/SavedArks/*.arkprofile
fi
cd ${GameRootDir}/${InstanceName}/ShooterGame/Saved
tar -xf ${Filename} > /dev/null 2>&1
ReturnValue=$?
if [ ${ReturnValue} -ne 0 ]; then
  ## Extract command failed.  Display warning message ##
  printf "[ERROR] Extract return value = {$ReturnValue}\n" | tee -a ${LogFile}
  f_abort 3
fi
## Sanity check...make sure at least the map is there ##
if [ ! -f ${GameRootDir}/${InstanceName}/ShooterGame/Saved/SavedArks/*.ark ]; then
  printf "[ERROR] A map file was not found in ${GameRootPath}/${InstanceName}/ShooterGame/Saved/SavedArks\n" | tee -a ${LogFile}
  f_abort 4
fi
printf "`date +%Y-%m-%d\ %H:%M:%S` - Restore completed.\n" | tee -a ${LogFile}
printf "FYI - Do not forget to start the instance.\n"
exit 0
