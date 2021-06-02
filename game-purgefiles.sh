#!/bin/bash
#############################################################
## Name          : game-purgefiles.sh
## Version       : 1.0
## Date          : 2020-10-08
## Author        : LHammonds
## Purpose       : Purge files older than x days
## Compatibility : Verified on to work on Ubuntu Server 20.04 LTS
## Requirements  : Run as root or the specified install user.
## Run Frequency : As needed (such as daily)
## Exit Codes    :
##     0 = Normal exit.
##   200 = ERROR Invalid user.
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2020-10-08 1.0 LTH Created script.
#############################################################

## Import common variables and functions. ##
source /etc/gamectl.conf

LogFile="${LogDir}/game-purgefiles.log"
Default=15

#######################################
##            FUNCTIONS              ##
#######################################

function f_purge()
{
  Folder=$1
  FilePattern=$2
  Days=$3
  ## Document files to be deleted in the log ##
  f_verbose "[INFO] ${Folder}/${FilePattern} +${Days}"
  if [ "${Verbose}" == "1" ]; then
    /usr/bin/find ${Folder} -maxdepth 1 -name "${FilePattern}" -mtime +${Days} -type f -exec /usr/bin/ls -l {} \; >> ${LogFile}
  fi
  /usr/bin/find ${Folder} -maxdepth 1 -name "${FilePattern}" -mtime +${Days} -type f -delete 1>/dev/null 2>&1
}  ## f_purge() ##

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameUser}" ]; then
  printf "[ERROR] This script must be run as root or ${GameUser}.\n"
  exit 200
fi

#######################################
##           MAIN PROGRAM            ##
#######################################

printf "`date +%Y-%m-%d_%H:%M:%S` - Purge started.\n" | tee -a ${LogFile}
f_purge ${BackupDir}/cluster *.7z ${Default}
f_purge ${BackupDir}/config *.7z ${Default}
f_purge ${BackupDir}/map *.7z ${Default}
f_purge ${BackupDir}/log *.7z ${Default}
f_purge ${BackupDir}/scripts *.7z ${Default}
printf "`date +%Y-%m-%d_%H:%M:%S` - Purge completed.\n" | tee -a ${LogFile}
exit 0
