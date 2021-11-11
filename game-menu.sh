#!/bin/bash
#############################################################
## Name          : game-menu.sh
## Version       : 1.0
## Date          : 2021-04-20
## Author        : LHammonds
## Purpose       : Menu for various scripts.
## Compatibility : Verified on Ubuntu Server 20.04 LTS
## Requirements  : Run as root
## Run Frequency : As needed.
## Parameters    : None
## Exit Codes    : None
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

function f_pause()
{
  printf "\nPress any key to continue\n"
  while [ true ] ; do
    read -n 1
    if [ $? = 0 ] ; then
      break ;
    fi
  done
}

function f_menu_utilities()
{
  local char_answer
  while [ true ]; do
    clear
    printf "\n"
    printf "=====================\n"
    printf "|| Menu: Utilities ||\n"
    printf "=====================\n"
    printf "b) Backup all instances\n"
    printf "r) Restore an instance\n"
    printf "f) Fix/Reset file permissions (takes a few minutes)\n"
    printf "p) Purge old archive files\n"
    printf "e) Edit gamectl.conf\n"
    printf "1) View backup log\n"
    printf "2) View restore log\n"
    printf "3) View fix log\n"
    printf "4) View purge log\n"
    printf "x) Exit\n"
    read -n 1 -p "Your choice: " char_answer;
    case ${char_answer} in
      b|B)
        clear
        printf "\n"
        ${ScriptDir}/game-backup.sh
        f_pause;;
      r|R)
        clear
        printf "\n"
        ${ScriptDir}/game-restore-map.sh
        f_pause;;
      f|F)
        printf "\n"
        ${ScriptDir}/game-fixperms.sh
        f_pause;;
      p|P)
        printf "\n"
        ${ScriptDir}/game-purgefiles.sh
        f_pause;;
      e|E)
        printf "\n"
        vi /etc/gamectl.conf;;
      1)
        printf "\n"
        vi ${LogDir}/game-backup.log;;
      2)
        printf "\n"
        vi ${LogDir}/game-restore-map.log;;
      3)
        printf "\n"
        vi ${LogDir}/game-fixperms.log;;
      4)
        printf "\n"
        vi ${LogDir}/game-purgefiles.log;;
      x|X)
        printf "\n\n"
        break;;
    esac
  done
}

function f_menu_control_service()
{
  local char_answer
  while [ true ]; do
    clear
    printf "\n"
    printf "===========================\n"
    printf "|| Menu: Service Control ||\n"
    printf "===========================\n"
    printf "s) Status\n"
    printf "1) Start 1 service\n"
    printf "2) Start all services\n"
    printf "3) Stop 1 service\n"
    printf "4) Stop all services\n"
    printf "5) View start log\n"
    printf "6) View stop log\n"
    printf "x) Exit to Main Menu\n\n"
    read -n 1 -p "Your choice: " char_answer;
    case ${char_answer} in
      s|S)
        clear
        printf "\n"
        ${ScriptDir}/game-listall.sh
        f_pause;;
      1)
        printf "\n"
        ${ScriptDir}/game-start-1.sh
        f_pause;;
      2)
        printf "\n"
        ${ScriptDir}/game-start-all.sh
        f_pause;;
      3)
        printf "\n"
        ${ScriptDir}/game-stop-1.sh
        f_pause;;
      4)
        printf "\n"
        ${ScriptDir}/game-stop-all.sh
        f_pause;;
      5)
        printf "\n"
        vi ${LogDir}/game-start.log;;
      6)
        printf "\n"
        vi ${LogDir}/game-stop.log;;
      x|X)
        printf "\n\n"
        break;;
    esac
  done
}

function f_menu_control_update()
{
  local char_answer
  while [ true ]; do
    clear
    printf "\n"
    printf "==========================\n"
    printf "|| Menu: Update Control ||\n"
    printf "==========================\n"
    printf "      Update Control\n\n"
    printf "c) Compare template server to instances\n"
    printf "m) Compare template mods to instance mods\n"
    printf "v) Verify template against Steam version\n"
    printf "1) Update server template\n"
    printf "2) Update mod template\n"
    printf "3) Sync template to 1 offline instance\n"
    printf "4) Sync template to all offline instances\n"
    printf "5) View Compare server log\n"
    printf "6) View Compare mods log\n"
    printf "7) View Update server log\n"
    printf "8) View Update mods log\n"
    printf "9) View Sync log\n"
    printf "x) Exit to Main Menu\n\n"
    read -n 1 -p "Your choice: " char_answer;
    case ${char_answer} in
      c|C)
        printf "\n"
        ${ScriptDir}/game-compare-server.sh
        f_pause;;
      m|M)
        printf "\n"
        ${ScriptDir}/game-compare-mods.sh
        f_pause;;
      v|V)
        printf "\n"
        ${ScriptDir}/game-verify.sh
        f_pause;;
      1)
        printf "\n"
        ${ScriptDir}/game-update-server.sh
        f_pause;;
      2)
        printf "\n"
        ${ScriptDir}/game-update-mods.sh
        f_pause;;
      3)
        printf "\n"
        ${ScriptDir}/game-sync-1.sh
        f_pause;;
      4)
        printf "\n"
        ${ScriptDir}/game-sync-all.sh
        f_pause;;
      5)
        printf "\n"
        vi ${LogDir}/game-compare-server.log;;
      6)
        printf "\n"
        vi ${LogDir}/game-compare-mods.log;;
      7)
        printf "\n"
        vi ${LogDir}/game-update-server.log;;
      8)
        printf "\n"
        vi ${LogDir}/game-update-mods.log;;
      9)
        printf "\n"
        vi ${LogDir}/game-sync-server.log;;
      x|X)
        printf "\n\n"
        break;;
    esac
  done
}

function f_mainmenu()
{
  local char_answer
  while [ True ]; do
    clear
    printf "\n================\n"
    printf "|| Menu: Main ||\n"
    printf "================\n"
    printf "s) Service Control\n"
    printf "u) Update Control\n"
    printf "t) Utilities\n"
    printf "x) Exit\n\n"
    read -n 1 -p "Your choice: " char_answer;
    case ${char_answer} in
      s|S)
        f_menu_control_service;;
      u|U)
        f_menu_control_update;;
      t|T)
        f_menu_utilities;;
      x|X)
        printf "\n\n"
        exit 0;;
    esac
  done
}

#######################################
##          PREREQUISITES            ##
#######################################

## Verify required user access ##
if [ "${USER}" != "root" ]; then
  printf "[ERROR] This script must be run as root.\n"
  exit 1
fi

#######################################
##           MAIN PROGRAM            ##
#######################################

f_mainmenu
exit 0
