#!/bin/bash
#############################################################
## Name          : game-compare-server.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Compare game engine version between template and instances.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root, the specified low-rights or install user.
## Run Frequency : As needed.
## Parameters    : None
## Exit Codes    :
##    0 = Current: Template matches all instance versions
##    1 = OutDated: Template does not match one or more instance versions
##    2 = Other Error
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

LogFile="${LogDir}/game-compare-server.log"
MatchStatus=0

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access. ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameUser}" ] && [ "${USER}" != "${GameService}" ]; then
  printf "[ERROR] This script must be run as root or ${GameUser}.\n"
  exit 2
fi

#######################################
##              MAIN                 ##
#######################################

printf "`date +%Y-%m-%d\ %H:%M:%S` - Started server comparison.\n" | tee -a ${LogFile}
## Get version number of template ##
if [ -f ${TemplateDir}/version.txt ]; then
  read -r TemplateVer < ${TemplateDir}/version.txt
  ## Remote newline, carriage return or spaces from variable ##
  TemplateVer=${TemplateVer//$'\n'/}
  TemplateVer=${TemplateVer//$'\r'/}
  TemplateVer=${TemplateVer//$' '/}
  printf "[CURRENT] ${TemplateVer} - template\n" | tee -a ${LogFile}
else
  printf "[ERROR] Missing version file: ${TemplateDir}/version.txt\n" | tee -a ${LogFile}
fi
## Loop through all valid instances and get their version ##
intVersion=0
for intIndex in "${!arrInstanceName[@]}"
do
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    if [ -f ${GameRootDir}/${arrInstanceName[${intIndex}]}/version.txt ]; then
      read -r InstanceVer < ${GameRootDir}/${arrInstanceName[${intIndex}]}/version.txt
      ## Remote newline, carriage return or spaces from variable ##
      InstanceVer=${InstanceVer//$'\n'/}
      InstanceVer=${InstanceVer//$'\r'/}
      InstanceVer=${InstanceVer//$' '/}
      if [ "${TemplateVer}" == "${InstanceVer}" ]; then
        printf "[CURRENT] ${InstanceVer} - ${arrInstanceName[${intIndex}]}\n" | tee -a ${LogFile}
      else
        printf "[OLD-VER] ${InstanceVer} - ${arrInstanceName[${intIndex}]}\n" | tee -a ${LogFile}
        MatchStatus=1
      fi
    else
      ## Missing the expected version file ##
      printf "[ERROR] Missing version file: ${GameRootDir}/${arrInstanceName[${intIndex}]}/version.txt\n"
    fi
  fi
done
if [ "${MatchStatus}" == "0" ]; then
  printf "[INFO] All instances match the template version of ${TemplateVer}\n" | tee -a ${LogFile}
else
  printf "[WARNING] One or more instances do not match template version of ${TemplateVer}\n" | tee -a ${LogFile}
fi
printf "`date +%Y-%m-%d\ %H:%M:%S` - Completed server comparison.\n" | tee -a ${LogFile}
exit ${MatchStatus}
