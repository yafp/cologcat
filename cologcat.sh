#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------
# NAME:         cologcat
#
# FUNCTION:     Colorize the output of 'adb logcat'
#
# HOWTO:        ./cologcat.sh
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
ADB_LOGCAT_COMMAND="adb logcat"



# ----------------------------------------------------------------------------------------------------------------------------
# CONSTANTS
# ----------------------------------------------------------------------------------------------------------------------------
readonly PROJECT_NAME="CoLogCat"
readonly PROJECT_URL="https://github.com/yafp/cologcat"
readonly PROJECT_VERSION="20170123.01"



# ----------------------------------------------------------------------------------------------------------------------------
# INIT TERMINAL
# ----------------------------------------------------------------------------------------------------------------------------
function initTerm() {
    clear
    
    # http://www.network-science.de/ascii/
    printf '\n'
    printf '_________        .____                 _________         __   \n'
    printf '\_   ___ \  ____ |    |    ____   ____ \_   ___ \_____ _/  |_ \n'
    printf '/    \  \/ /  _ \|    |   /  _ \ / ___\/    \  \/\__  \\   __\\\n'
    printf '\     \___(  <_> )    |__(  <_> ) /_/  >     \____/ __ \|  |  \n'
    printf " \______  /\____/|_______ \____/\___  / \______  (____  /__|  $PROJECT_VERSION\n"
    printf "       \/               \/    /_____/         \/     \/      \n\n"
}



# ----------------------------------------------------------------------------------------------------------------------------
# INIT COLORS
# ----------------------------------------------------------------------------------------------------------------------------
function initColors() {
    printf "Initializing colors\n"
    # format
    BOLD=$(tput bold)           # Start BOLD text
    NORMAL=$(tput sgr0)         # Turn off all attributes
    BLINK=$(tput blink)         # Start BLINKing text
    REVERSE=$(tput smso)        # Start "standout" mode
    FOO=$(tput rmso)            # End "standout" mode
    UNDERLINE=$(tput smul)      # Start UNDERLINEd text
    ENDUNDERLINE=$(tput rmul)   # End UNDERLINEd text

    # http://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
    #
    # Color     #define         Value   RGB
    # ------------------------------------------
    # black     COLOR_BLACK       0     0, 0, 0
    # red       COLOR_RED         1     max,0,0
    # green     COLOR_GREEN       2     0,max,0
    # yellow    COLOR_YELLOW      3     max,max,0
    # blue      COLOR_BLUE        4     0,0,max
    # magenta   COLOR_MAGENTA     5     max,0,max
    # cyan      COLOR_CYAN        6     0,max,max
    # white     COLOR_WHITE       7     max,max,max
    
    
    # http://linuxcommand.org/lc3_adv_tput.php
    #
    # setaf     = Foreground
    # setab     = background
    
    # Foreground
    #
    FG_BLACK=$(tput setaf 0)
    FG_RED=$(tput setaf 1)
    FG_GREEN=$(tput setaf 2)
    FG_YELLOW=$(tput setaf 3)
    FG_BLUE=$(tput setaf 4)
    FG_MAGENTA=$(tput setaf 5)
    FG_CYAN=$(tput setaf 6)
    FG_WHITE=$(tput setaf 7)
    # 8  = not used
    FG_DEFAULT=$(tput setaf 9)
    #
    FG_LIME_YELLOW=$(tput setaf 190)
    FG_POWDER_BLUE=$(tput setaf 153)
    
    
    # Background
    #
    BG_BLACK=$(tput setab 0)
    BG_RED=$(tput setab 1)
    BG_GREEN=$(tput setab 2)
    BG_YELLOW=$(tput setab 3)
    BG_BLUE=$(tput setab 4)
    BG_MAGENTA=$(tput setab 5)
    BG_CYAN=$(tput setab 6)
    BG_WHITE=$(tput setab 7)
    # 8  = not used
    BG_DEFAULT=$(tput setab 9)
    #
    BG_LIME_YELLOW=$(tput setab 190)
    BG_POWDER_BLUE=$(tput setab 153)
    
    printf "${FG_GREEN}[   OK   ]${NORMAL}\tColors initialized\n\n"
}



# ----------------------------------------------------------------------------------------------------------------------------
# CHECK REQUIREMENTS (ADB)
# ----------------------------------------------------------------------------------------------------------------------------
function checkRequirements() {
    printf "Checking requirements\n"
    
    # adb (required)
    if hash adb 2>/dev/null; then
            printf " ${FG_GREEN}[   OK   ]${NORMAL}\tFound ADB\n"
        else
            printf " ${FG_RED}[  FAIL  ]${NORMAL}\tADB is missing\n"
            exit 1
    fi
    
    # whiptail (optional)
    if hash whiptail 2>/dev/null; then # check for whiptail
        printf " ${FG_GREEN}[   OK   ]${NORMAL}\tFound whiptail\n\n"
    else
        printf " ${FG_YELLOW}[ WARNING]${NORMAL}\tFiltering is not possible as whiptail is missing\n\n"
    fi
}



# ----------------------------------------------------------------------------------------------------------------------------
#  CONFIGURE LOGCAT LEVEL
# ----------------------------------------------------------------------------------------------------------------------------
function setLogCatLevel() {
    printf "Checking input filter\n"
    
     if hash whiptail 2>/dev/null; then # check for whiptail
            OPTION=$(whiptail --title "Set LogCat Level" --backtitle "$PROJECT_NAME" --ok-button "Choose" --cancel-button "Exit (ESC)" --menu "Configure LogCat level" 16 70 8 \
        "[S]" "Silent" \
        "[V]" "Verbose" \
        "[D]" "Debug" \
        "[I]" "Info" \
        "[W]" "Warning" \
        "[E]" "Error" \
        "[F]" "Fatal" 3>&1 1>&2 2>&3)
         
        EXITSTATUS=$?
        if [ $EXITSTATUS = 0 ]; then
            case $OPTION in
                "[V]")
                    ADB_LOGCAT_COMMAND="adb logcat *:V"
                    ;;
                "[D]") 
                    ADB_LOGCAT_COMMAND="adb logcat *:D"
                    ;;
                "[I]")
                    ADB_LOGCAT_COMMAND="adb logcat *:I"
                    ;;
                "[W]") 
                    ADB_LOGCAT_COMMAND="adb logcat *:W"
                    ;;
                "[E]") 
                    ADB_LOGCAT_COMMAND="adb logcat *:E"
                    ;;
                "[F]") 
                    ADB_LOGCAT_COMMAND="adb logcat *:F"
                    ;;
                "[S]") 
                    ADB_LOGCAT_COMMAND="adb logcat *:S"
                    ;;
            esac
        else # user aborted whiptail dialog
            printf " ${FG_RED}[  FAIL  ]${NORMAL}\tAborted by user\n\n"
            exit
        fi
        startADBLogcat
    else # whiptail is missing
        printf " ${FG_RED}[  FAIL  ]${NORMAL}\tCan't show dialog as whiptail is missing\n\n"
    fi
}



# ----------------------------------------------------------------------------------------------------------------------------
# CHECK STARTUP PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------------
function checkParameters() {
    printf "Checking parameters\n"
    case "$primaryParameter" in
        "-h" | "--help")
            printf " ${FG_GREEN}[   OK   ]${NORMAL}\tRequesting help\n"
            displayHelp
            ;;
         "-f" | "--filter")
            setLogCatLevel
            ;;
        *)
            printf " ${FG_RED}[  FAIL  ]${NORMAL}\tUnsupported parameter '$primaryParameter'\n\n"
            ;;
    esac
}



# ----------------------------------------------------------------------------------------------------------------------------
# DISPLAY HELP INFORMATIONS
# ----------------------------------------------------------------------------------------------------------------------------
function displayHelp() {
    initTerm
    printf "\n$PROJECT_NAME help\n\n"
    printf "  Name:\t\t$PROJECT_NAME\n"
    printf "  Version:\t$PROJECT_VERSION\n"
    printf "  URL:\t\t$PROJECT_URL\n\n"
    printf "Parameter:\n"
    printf "  -f /--filter\tset log-level filter\n"
    printf "  -h / --help\tshow help\n"
}



# ----------------------------------------------------------------------------------------------------------------------------
# COLORIZE MESSAGETYPE
# ----------------------------------------------------------------------------------------------------------------------------
function colorizeOutput() {

    case $MSG_TYPE in
        [A]*)                                       #   A = Assert
        
            COLOR_LONG=${FG_LIME_YELLOW}
            COLOR_SHORT=${BG_LIME_YELLOW}${FG_BLACK}
            
            cMSG_TYPE_LONG="${FG_LIME_YELLOW}[  Assert ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_LIME_YELLOW}${FG_BLACK} A ${NORMAL}"
            
            cMSG_SOURCE="${FG_LIME_YELLOW}$MSG_SOURCE${NORMAL}"
            ;;
            
        [D]*)                                       #   D = Debug
            cMSG_TYPE_LONG="${FG_BLUE}[  Debug  ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_BLUE}${FG_BLACK} D ${NORMAL}"
            
            cMSG_SOURCE="${FG_BLUE}$MSG_SOURCE${NORMAL}"
            ;;
            
        [E])                                        #   E = Error
            cMSG_TYPE_LONG="${FG_RED}[  Error  ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_RED}${FG_BLACK} E ${NORMAL}"
            
            cMSG_SOURCE="${FG_RED}$MSG_SOURCE${NORMAL}"
            ;;
            
        [F])                                        #   F = Fatal
            cMSG_TYPE_LONG="${FG_MAGENTA}[  Fatal  ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_MAGENTA}${FG_BLACK} F ${NORMAL}"
            
            cMSG_SOURCE="${FG_MAGENTA}$MSG_SOURCE${NORMAL}"
            ;;
            
        [I])                                        #   I = Info
            cMSG_TYPE_LONG="${FG_GREEN}[   Info  ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_GREEN}${FG_BLACK} I ${NORMAL}"
            
            cMSG_SOURCE="${FG_GREEN}$MSG_SOURCE${NORMAL}"
            ;;
            
        [S])                                        #   S = Silent
            cMSG_TYPE_LONG="${FG_POWDER_BLUE}[  Silent ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_POWDER_BLUE}${FG_BLACK} S ${NORMAL}"
            
            cMSG_SOURCE="${FG_POWDER_BLUE}$MSG_SOURCE${NORMAL}"
            ;;
            
        [V])                                        #   V = Verbose
            cMSG_TYPE_LONG="${FG_CYAN}[ Verbose ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_CYAN}${FG_BLACK} V ${NORMAL}"
            
            cMSG_SOURCE="${FG_CYAN}$MSG_SOURCE${NORMAL}"
            ;;
            
        [W])                                        #   W = Warning
            cMSG_TYPE_LONG="${FG_YELLOW}[ Warning ]${NORMAL}"
            cMSG_TYPE_SHORT="${BG_YELLOW}${FG_BLACK} W ${NORMAL}"
            
            cMSG_SOURCE="${FG_YELLOW}$MSG_SOURCE${NORMAL}"
            ;;
            
        *)
            cMSG_TYPE_LONG="[   $MSG_TYPE   ]"
            cMSG_TYPE_SHORT="$MSG_TYPE"
            
            cMSG_SOURCE="$MSG_SOURCE"
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
    MSG_SOURCE="${lineCols[5]}"

    # message is difficult to handle col-wise
    MSG="${line##*$MSG_SOURCE" "}" # everything after msg_source is the actual msg

    # colorize some output values
    colorizeOutput

    # original output of logcat
    #printf "$line\n"
    #
    # Default order or 
    #printf "$DATE $TIME $PROCESS_ID $THREAD_ID $MSG_TYPE $MSG\n"
    #
    # coLogCat output
    printf " $cMSG_TYPE_LONG $DATE $TIME $cMSG_TYPE_SHORT $PROCESS_ID\t $THREAD_ID\t $cMSG_SOURCE $MSG\n"
    #printf "$DATE $TIME $PROCESS_ID $THREAD_ID $cMSG_TYPE_SHORT $MSG\n"
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
initTerm
initColors
checkRequirements

if [ $# -eq 0 ]; then # if no parameter was supplied
    startADBLogcat
else # if parameters were supplied - check them
    primaryParameter=$1
    checkParameters
fi

