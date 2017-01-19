#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------
# NAME:         cologcat
#
# VERSION:      20170119.01
#
# FUNCTION:     Colorize the output of 'adb logcat'
#
# HOWTO:
#               ./cologcat.sh
#
# MORE:
#               Example output of logcat:
#                   01-18 15:03:22.844  2746  2746 D wpa_supplicant: wlan0: Radio work 'scan'@0xb67a0210 done in 0.493416 seconds
#
# BY:           yafp
# ----------------------------------------------------------------------------------------------------------------------------




# ----------------------------------------------------------------------------------------------------------------------------
# CONFIG
# ----------------------------------------------------------------------------------------------------------------------------
# adb logcat *:F                              Show only log entries of type FATAL
# adb logcat | grep 123                       Show only log entries for PID 123
#
ADB_LOGCAT_COMMAND="adb logcat"




# ----------------------------------------------------------------------------------------------------------------------------
# CONSTANTS
# ----------------------------------------------------------------------------------------------------------------------------
readonly PROJECT_NAME="CoLogCat"
readonly PROJECT_URL="https://github.com/yafp/cologcat"



# ----------------------------------------------------------------------------------------------------------------------------
# INIT TERMINAL
# ----------------------------------------------------------------------------------------------------------------------------
function initTerm() {
    clear
    printf " $PROJECT_NAME\n\n"

}

# ----------------------------------------------------------------------------------------------------------------------------
# INIT COLORS
# ----------------------------------------------------------------------------------------------------------------------------
function initColors() {
    printf "Initializing colors\n"
    # format
    bold=$(tput bold)
    normal=$(tput sgr0)
    blink=$(tput blink)
    reverse=$(tput smso)
    underline=$(tput smul)
    
    # colors
    black=$(tput setaf 0)
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    magenta=$(tput setaf 5)
    cyan=$(tput setaf 6)
    white=$(tput setaf 7)
    #
    lime_yellow=$(tput setaf 190)
    powder_blue=$(tput setaf 153)
    
    printf "${green}[   OK   ]${normal}\tColors initialized\n\n"
}



# ----------------------------------------------------------------------------------------------------------------------------
# CHECK REQUIREMENTS (ADB)
# ----------------------------------------------------------------------------------------------------------------------------
function checkRequirements() {
    printf "Checking requirements\n"
    if hash adb 2>/dev/null; then
            printf "${green}[   OK   ]${normal}\tFound ADB\n\n"
        else
            printf "${red}[  FAIL  ]${normal}\tADB is missing\n\n"
            exit 1
    fi
}



# ----------------------------------------------------------------------------------------------------------------------------
# CHECK STARTUP PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------------
function checkParameters() {
    case "$primaryParameter" in
        "-h" | "--help")
            displayHelp
            ;;
    esac
}



# ----------------------------------------------------------------------------------------------------------------------------
# DISPLAY HELP INFORMATIONS
# ----------------------------------------------------------------------------------------------------------------------------
function displayHelp() {
    clear
    printf "\tName:\t$PROJECT_NAME\n"
    printf "\tURL:\t$PROJECT_URL\n\n"
}

# ----------------------------------------------------------------------------------------------------------------------------
# COLORIZE MESSAGETYPE
# ----------------------------------------------------------------------------------------------------------------------------
function colorizeMessageType() {

    case $MSG_TYPE in
    [A]*)                                       #   A = Assert
      MSG_TYPE=" ${red}[  Assert ]${normal}"
      ;;
    [D]*)                                       #   D = Debug
      MSG_TYPE=" ${blue}[  Debug  ]${normal}"
      ;;
    [E])                                        #   E = Error
      MSG_TYPE=" ${red}[  Error  ]${normal}"
      ;;
    [F])                                        #   F = Fatal
      MSG_TYPE=" ${magenta}[  Fatal  ]${normal}"
      ;;
    [I])                                        #   I = Info
      MSG_TYPE=" ${green}[   Info  ]${normal}"
      ;;
    [S])                                        #   S = Silent
      MSG_TYPE=" ${powder_blue}[  Silent ]${normal}"
      ;;
    [V])                                        #   V = Verbose
      MSG_TYPE=" ${cyan}[ Verbose ]${normal}"
      ;;
    [W])                                        #   W = Warning
      MSG_TYPE=" ${yellow}[ Warning ]${normal}"
      ;;
    *)
      MSG_TYPE="[   $MSG_TYPE   ]"
      ;;
    esac
}



# ----------------------------------------------------------------------------------------------------------------------------
# PARSE SINGLE LOGCAT OUTPUT LINE
# ----------------------------------------------------------------------------------------------------------------------------
function parseLogcatOutputLine() {
        lineCols=( $line ) ;
        
        # store column content to individual variables
        #
        DATE="${lineCols[0]}" 
        TIME="${lineCols[1]}" 
        PROCESS_ID="${lineCols[2]}"
        THREAD_ID="${lineCols[3]}"
        MSG_TYPE="${lineCols[4]}"
        
        # message is difficult to handle col-wise
        # current implementation is cutting first letter in some cases.
        MSG="${line##*$MSG_TYPE}" # everything after msg_type is the actual msg
        
        # colorize message type
        colorizeMessageType "$MSG_TYPE"

        # Output
        printf "$MSG_TYPE\t $DATE $TIME\t $PROCESS_ID\t $THREAD_ID\t$MSG\n"
}



# ----------------------------------------------------------------------------------------------------------------------------
# START ADBLOGCAT
# ----------------------------------------------------------------------------------------------------------------------------
function startADBLogcat() {
    printf "Trying to connect to device\n"
    stdbuf -oL $ADB_LOGCAT_COMMAND |
        while IFS= read -r line
        do
            parseLogcatOutputLine
        done
}



# ----------------------------------------------------------------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------------------------------------------------------------
primaryParameter=$1
initTerm
initColors
checkRequirements

if [ $# -eq 0 ]; then # if no parameter was supplied
    startADBLogcat
else # if parameters were supplied - check them
    checkParameters
fi

