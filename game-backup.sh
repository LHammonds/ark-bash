#!/bin/bash
#############################################################
## Name          : game-backup.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Create archive of all game instances.
## Compatibility : Verified on Ubuntu Server 20.04
## Requirements  : Run as root or the specified install user.
## Run Frequency : Designed to run as needed.
## Exit Codes    :
##   0 = success
## 200 = ERROR Invalid user.
##   # = Number of times archive creation failed.
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2021-04-20 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /etc/gamectl.conf

LogFile="${LogDir}/game-backup.log"
TimeStamp="`date +%Y-%m-%d_%H-%M-%S`"
ArchivePattern="_ark.tar.gz"
RsyncFailure=0
ErrorFlag=0
StartTime="$(date +%s)"

#######################################
##            FUNCTIONS              ##
#######################################

function f_sendmsg()
{
  ## Parameter #1 = RCON Port ##
  ## Parameter #2 = RCON Command ##
  ${ScriptDir}/rcon -f /etc/rcon.ini -p ${1} "${2}"
}   ## f_sendmsg() ##

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access. ##
if [ "${USER}" != "root" ] && [ "${USER}" != "${GameUser}" ]; then
  printf "[ERROR] This script must be run as root or ${GameUser}.\n"
  exit 200
fi

#######################################
##           MAIN PROGRAM            ##
#######################################

printf "`date +%Y-%m-%d\ %H:%M:%S` - Backup started.\n" | tee -a ${LogFile}

## Create specific backup target folders if the do not exist ##
if [ ! -d ${BackupDir}/map ]; then
  mkdir ${BackupDir}/map
fi
if [ ! -d ${BackupDir}/log ]; then
  mkdir ${BackupDir}/log
fi
if [ ! -d ${BackupDir}/config ]; then
  mkdir ${BackupDir}/config
fi
if [ ! -d ${BackupDir}/cluster ]; then
  mkdir ${BackupDir}/cluster
fi
if [ ! -d ${BackupDir}/scripts ]; then
  mkdir ${BackupDir}/scripts
fi

## Cluster backup ##
cd ${GameRootDir}/cluster
tar -czpf ${BackupDir}/cluster/${TimeStamp}_cluster.tar.gz * 1>/dev/null 2>&1
if [ ! -f ${BackupDir}/cluster/${TimeStamp}_cluster.tar.gz ]; then
  ## Error detected ##
  printf "`date +%Y-%m-%d\ %H:%M:%S` [ERROR] Failed to create ${BackupDir}/cluster/${TimeStamp}_cluster.tar.gz.\n" | tee -a ${LogFile}
  ((ErrorFlag++))
else
  ## Record some stats to the log file ##
  ArchiveSize=`ls -lh "${BackupDir}/cluster/${TimeStamp}_cluster.tar.gz" | awk '{ print $5 }'`
  f_verbose "[FILE] ${ArchiveSize}, ${BackupDir}/cluster/${TimeStamp}_cluster.tar.gz"
fi

## Scripts backup ##
cd ${GameRootDir}/scripts
tar -czpf ${BackupDir}/scripts/${TimeStamp}_scripts.tar.gz * 1>/dev/null 2>&1
if [ ! -f ${BackupDir}/scripts/${TimeStamp}_scripts.tar.gz ]; then
  ## Error detected ##
  printf "`date +%Y-%m-%d\ %H:%M:%S` [ERROR] Failed to create ${BackupDir}/scripts/${TimeStamp}_scripts.tar.gz.\n" | tee -a ${LogFile}
  ((ErrorFlag++))
else
  ## Record some stats to the log file ##
  ArchiveSize=`ls -lh "${BackupDir}/scripts/${TimeStamp}_scripts.tar.gz" | awk '{ print $5 }'`
  f_verbose "[FILE] ${ArchiveSize}, ${BackupDir}/scripts/${TimeStamp}_scripts.tar.gz"
fi

## Loop through each game instance ##
for intIndex in "${!arrInstanceName[@]}"
do
  MapName=${arrMapName[${intIndex}]}
  RCONPort=${arrRCONPort[${intIndex}]}
  InstanceName=${arrInstanceName[${intIndex}]}
  ## Verify instance is installed ##
  if [ -f "${GameRootDir}/${arrInstanceName[${intIndex}]}/ShooterGame/Binaries/Linux/ShooterGameServer" ]; then
    ## Check if instance is running ##
    ${ScriptDir}/game-online.sh ${arrInstanceName[${intIndex}]} > /dev/null 2>&1
    ReturnCode=$?
    if [ "${ReturnCode}" == "1" ]; then
      ## Instance is active. Send in-game notice ##
      f_sendmsg ${RCONPort} "ServerChat `date +%H:%M` Backup started."
      f_sendmsg ${RCONPort} "SaveWorld"
    fi
    ## Create map archive ##
    cd ${GameRootDir}/${InstanceName}/ShooterGame/Saved
    tar -czpf ${BackupDir}/map/${TimeStamp}_${InstanceName}.tar.gz SavedArks/${MapName}.ark SavedArks/*.arktribe SavedArks/*.arkprofile SavedArks/*.arktributetribe > /dev/null 2>&1
    if [ ! -f ${BackupDir}/map/${TimeStamp}_${InstanceName}.tar.gz ]; then
      ## Error detected ##
      printf "`date +%Y-%m-%d\ %H:%M:%S` [ERROR] Failed to create ${BackupDir}/map/${TimeStamp}_${InstanceName}.tar.gz.\n" | tee -a ${LogFile}
      ((ErrorFlag++))
    else
      ## Record some stats to the log file ##
      ArchiveSize=`ls -lh "${BackupDir}/map/${TimeStamp}_${InstanceName}.tar.gz" | awk '{ print $5 }'`
      f_verbose "[FILE] ${ArchiveSize}, ${BackupDir}/map/${TimeStamp}_${InstanceName}.tar.gz"
      if [ "${ReturnCode}" == "1" ]; then
        ## Instance is active. Send in-game notice ##
      f_sendmsg ${RCONPort} "ServerChat `date +%H:%M` Backup completed. Archive size = ${ArchiveSize}"
      fi
    fi
    ## Create log archive ##
    cd ${GameRootDir}/${InstanceName}/ShooterGame/Saved/Logs
    tar -czpf ${BackupDir}/log/${TimeStamp}_${InstanceName}-log.tar.gz *.log 1>/dev/null 2>&1
    if [ ! -f ${BackupDir}/log/${TimeStamp}_${InstanceName}-log.tar.gz ]; then
      ## Error detected ##
      printf "`date +%Y-%m-%d\ %H:%M:%S` [ERROR] Failed to create ${BackupDir}/log/${TimeStamp}_${InstanceName}-log.tar.gz.\n" | tee -a ${LogFile}
      ((ErrorFlag++))
    else
      ## Record some stats to the log file ##
      ArchiveSize=`ls -lh "${BackupDir}/log/${TimeStamp}_${InstanceName}-log.tar.gz" | awk '{ print $5 }'`
      f_verbose "[FILE] ${ArchiveSize}, ${BackupDir}/log/${TimeStamp}_${InstanceName}-log.tar.gz"
    fi
    ## Create config archive ##
    cd ${GameRootDir}/${InstanceName}/ShooterGame/Saved/Config/LinuxServer
    tar -czpf ${BackupDir}/config/${TimeStamp}_${InstanceName}-config.tar.gz *.ini 1>/dev/null 2>&1
    if [ ! -f ${BackupDir}/config/${TimeStamp}_${InstanceName}-config.tar.gz ]; then
      ## Error detected ##
      printf "`date +%Y-%m-%d\ %H:%M:%S` [ERROR] Failed to create ${BackupDir}/config/${TimeStamp}_${InstanceName}-config.tar.gz.\n" | tee -a ${LogFile}
      ((ErrorFlag++))
    else
      ## Record some stats to the log file ##
      ArchiveSize=`ls -lh "${BackupDir}/config/${TimeStamp}_${InstanceName}-config.tar.gz" | awk '{ print $5 }'`
      f_verbose "[FILE] ${ArchiveSize}, ${BackupDir}/config/${TimeStamp}_${InstanceName}-config.tar.gz"
    fi
  fi
done
## Calculate total runtime ##
FinishTime="$(date +%s)"
ElapsedTime="$(expr ${FinishTime} - ${StartTime})"
Hours=$((${ElapsedTime} / 3600))
ElapsedTime=$((${ElapsedTime} - ${Hours} * 3600))
Minutes=$((${ElapsedTime} / 60))
Seconds=$((${ElapsedTime} - ${Minutes} * 60))
printf "[INFO] Total runtime: ${Hours} hour(s) ${Minutes} minute(s) ${Seconds} second(s)\n" | tee -a ${LogFile}
printf "[INFO] Exit code = ${ErrorFlag}\n" | tee -a ${LogFile}
printf "`date +%Y-%m-%d\ %H:%M:%S` - Backup completed.\n" | tee -a ${LogFile}
exit ${ErrorFlag}
