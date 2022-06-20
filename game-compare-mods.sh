#!/bin/bash
#############################################################
## Name          : game-compare-mods.sh
## Version       : 1.1
## Date          : 2022-06-20
## Author        : LHammonds
## Purpose       : Compare mods in template to those in each instance.
## Compatibility : Verified on Ubuntu Server 20.04 / 22.04 LTS
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
## 2022-06-20 1.1 LTH Added missing LogFile variable.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

LogFile="${LogDir}/game-compare-mods.log"
MatchStatus=0
TotalCompares=0
TotalMismatched=0
MismatchList=""
CurrentMismatch=""

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access. ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameUser}" ] && [ "${USER}" != "${GameService}" ]; then
  printf "[ERROR] This script must be run as root, ${GameUser} or ${GameService}.\n"
  exit 2
fi

#######################################
##              MAIN                 ##
#######################################

printf "`date +%Y-%m-%d\ %H:%M:%S` - Started mod comparison.\n" | tee -a ${LogFile}
## Loop through all .mod files
cd ${TemplateDir}/ShooterGame/Content/Mods/
for TemplateFile in *.mod
do
  ## Loop through all instances
  for intIndex in "${!arrInstanceName[@]}"
  do
    ## Verify instance is installed ##
    if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Compare template .mod to instance .mod
      if cmp --silent "${TemplateDir}/ShooterGame/Content/Mods/${TemplateFile}" "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Content/Mods/${TemplateFile}"
      then
        ((TotalCompares++))
      else
        ((TotalCompares++))
        ((TotalMismatched++))
        MatchStatus=1
        if [ "${CurrentMismatch}" != "${arrInstanceName[${intIndex}]}" ]; then
          if [ "${MismatchList}" == "" ]; then
            MismatchList="${arrInstanceName[${intIndex}]}"
          else
            MismatchList="${MismatchList},${arrInstanceName[${intIndex}]}"
          fi
          CurrentMismatch=${arrInstanceName[${intIndex}]}
        fi
      fi
    fi
  done
done
if [ ${TotalMismatched} -eq 0 ]; then
  printf "[INFO] All mods match the template.\n" | tee -a ${LogFile}
else
  printf "[WARNING] There are ${TotalMismatched} instances with outdated mods.\n[OUTDATED] ${MismatchList}\n" | tee -a ${LogFile}
fi
printf "`date +%Y-%m-%d\ %H:%M:%S` - Completed mod comparison.\n" | tee -a ${LogFile}
exit ${MatchStatus}
