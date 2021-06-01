#!/bin/bash
#############################################################
## Name          : game-update-mods.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Update mods for the game template.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified install user.
## Run Frequency : As needed.
## Parameters    : None
## Exit Codes    :
##    0 = Success
##  200 = ERROR Incorrect user
##  201 = ERROR Invalid template path
##    ? = All other numbers are the sum of the total amount of errors.
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

ErrorCount=0
LogFile="${LogDir}/game-update-mods.log"
StartTime="$(date +%s)"

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access. ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameUser}" ]; then
  printf "[ERROR] This script must be run as root or ${GameUser}.\n"
  exit 200
fi

## Validate Template Folder ##
if [ ! -d "${TemplateDir}" ]; then
  printf "[ERROR] Invalid template path. ${TemplateDir} does not exist.\n"
  exit 201
fi

#######################################
##              MAIN                 ##
#######################################

printf "`date +%Y-%m-%d_%H:%M:%S` - Started mod update.\n" | tee -a ${LogFile}
if [ -d ${TempDir}/dumps ]; then
  ## Remove temporary folder used by ArkModDownloader ##
  rm -rf ${TempDir}/dumps
fi
for ModID in ${GameModIds//,/ }
do
  if [ -d ${TemplateDir}/steamapps/workshop/content/${GameID}/${ModID} ]; then
    ## Delete prior download folder ##
    rm -rf ${TemplateDir}/steamapps/workshop/content/${GameID}/${ModID}
  fi
  if [ -f ${TemplateDir}/steamapps/workshop/content/${GameID}/${ModID}.mod ]; then
    ## Delete prior mod descriptor file ##
    rm ${TemplateDir}/steamapps/workshop/content/${GameID}/${ModID}.mod
  fi
  if [ "${USER}" == "root" ]; then
    ## Switch to the install user and update the instance ##
    f_verbose "su --command='${ArkModDLCMD} --modids '${ModID}' --workingdir '${TemplateDir}' --steamcmd '${SteamDir}' --namefile' ${GameUser}"
    su --command="${ArkModDLCMD} --modids '${ModID}' --workingdir '${TemplateDir}' --steamcmd '${SteamDir}' --namefile" ${GameUser}
    ReturnCode=$?
  elif [ "${USER}" == "${GameUser}" ]; then
    ## Already running as the install user, update the instance ##
    f_verbose "${ArkModDLCMD} --modids '${ModID}' --workingdir '${TemplateDir}' --steamcmd '${SteamDir}' --namefile ${GameUser}"
    ${ArkModDLCMD} --modids "${ModID}" --workingdir "${TemplateDir}" --steamcmd "${SteamDir}" --namefile ${GameUser}
    ReturnCode=$?
  fi
  if [ "${ReturnCode}" == "0" ]; then
    printf "[SUCCESS] Mod ${ModID} downloaded.\n" | tee -a ${LogFile}
    chown --recursive ${GameUser}:${GameGroup} ${TemplateDir}/ShooterGame/Content/Mods/${ModID}*
    find ${TemplateDir}/ShooterGame/Content/Mods/${ModID} -type d -exec chmod 0750 {} \;
    find ${TemplateDir}/ShooterGame/Content/Mods/${ModID} -type f -exec chmod 0640 {} \;
  else
    printf "[ERROR] Mod ${ModID} failed with ReturnCode=${ReturnCode}\n" | tee -a ${LogFile}
    ((ErrorCount++))
  fi
done
f_verbose "[INFO] ErrorCount=${ErrorCount}"
## Calculate total runtime ##
FinishTime="$(date +%s)"
ElapsedTime="$(expr ${FinishTime} - ${StartTime})"
Hours=$((${ElapsedTime} / 3600))
ElapsedTime=$((${ElapsedTime} - ${Hours} * 3600))
Minutes=$((${ElapsedTime} / 60))
Seconds=$((${ElapsedTime} - ${Minutes} * 60))
printf "[INFO] Total runtime: ${Hours} hour(s) ${Minutes} minute(s) ${Seconds} second(s)\n" | tee -a ${LogFile}
printf "`date +%Y-%m-%d_%H:%M:%S` - Completed mod update.\n" | tee -a ${LogFile}
exit ${ErrorCount}
