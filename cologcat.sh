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
ADB_LOGCAT_COMMAND="adb logcat"



# ----------------------------------------------------------------------------------------------------------------------------
# CONSTANTS
# ----------------------------------------------------------------------------------------------------------------------------
readonly PROJECT_NAME="CoLogCat"
readonly PROJECT_URL="https://github.com/yafp/cologcat"
readonly PROJECT_VERSION="1.0.0"



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
    printf "\nConfiguring Logcat filter level\n"

     if hash whiptail 2>/dev/null; then # check for whiptail
            OPTION=$(whiptail --title "Set LogCat Level" --backtitle "$PROJECT_NAME" --ok-button "Choose" --cancel-button "Exit (ESC)" --menu "Configure LogCat logging level" 16 70 8 \
        "[V]" "Verbose (most)" \
        "[D]" "Debug" \
        "[I]" "Info" \
        "[W]" "Warning" \
        "[E]" "Error" \
        "[F]" "Fatal" \
        "[S]" "Silent (none)"  3>&1 1>&2 2>&3)

        EXITSTATUS=$?
        if [ $EXITSTATUS = 0 ]; then
            case $OPTION in
                "[V]")                                      # Verbose
                    ADB_LOGCAT_COMMAND="adb logcat *:V"
                    ;;
                "[D]")                                      # Debug
                    ADB_LOGCAT_COMMAND="adb logcat *:D"
                    ;;
                "[I]")                                      # Info
                    ADB_LOGCAT_COMMAND="adb logcat *:I"
                    ;;
                "[W]")                                      # Warning
                    ADB_LOGCAT_COMMAND="adb logcat *:W"
                    ;;
                "[E]")                                      # Error
                    ADB_LOGCAT_COMMAND="adb logcat *:E"
                    ;;
                "[F]")                                      # Fatal
                    ADB_LOGCAT_COMMAND="adb logcat *:F"
                    ;;
                "[S]")                                      # Silent
                    ADB_LOGCAT_COMMAND="adb logcat *:S"
                    ;;
            esac
        else # user aborted whiptail dialog
            printf " ${FG_RED}[  FAIL  ]${NORMAL}\tAborted by user\n\n"
            exit
        fi
    else # whiptail is missing
        printf " ${FG_RED}[  FAIL  ]${NORMAL}\tCan't show dialog as whiptail is missing\n\n"
    fi
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
    printf "  -f / --filter\tset logcat logging filter\n"
    printf "  -h / --help\tshow help\n"
    exit
}



# ----------------------------------------------------------------------------------------------------------------------------
# COLORIZE MESSAGETYPE
# ----------------------------------------------------------------------------------------------------------------------------
function colorizeOutput() {

    case $MSG_TYPE in
        [A]*)                                       #   A = Assert
            COLOR_FG_ONLY=${FG_LIME_YELLOW}
            COLOR_FB_AND_BG=${BG_LIME_YELLOW}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[  Assert ]"
            ;;

        [D]*)                                       #   D = Debug
            COLOR_FG_ONLY=${FG_BLUE}
            COLOR_FB_AND_BG=${BG_BLUE}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[   Debug ]"
            ;;

        [E])                                        #   E = Error
            COLOR_FG_ONLY=${FG_RED}
            COLOR_FB_AND_BG=${BG_RED}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[   Error ]"
            ;;

        [F])                                        #   F = Fatal
            COLOR_FG_ONLY=${FG_MAGENTA}
            COLOR_FB_AND_BG=${BG_MAGENTA}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[   Fatal ]"
            ;;

        [I])                                        #   I = Info
            COLOR_FG_ONLY=${FG_GREEN}
            COLOR_FB_AND_BG=${BG_GREEN}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[    Info ]"
            ;;

        [S])                                        #   S = Silent
            # colors
            COLOR_FG_ONLY=${FG_POWDER_BLUE}
            COLOR_FB_AND_BG=${BG_POWDER_BLUE}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[  Silent ]"
            ;;

        [V])                                        #   V = Verbose
            COLOR_FG_ONLY=${FG_CYAN}
            COLOR_FB_AND_BG=${BG_CYAN}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[ Verbose ]"
            ;;

        [W])                                        #   W = Warning
            COLOR_FG_ONLY=${FG_YELLOW}
            COLOR_FB_AND_BG=${BG_YELLOW}${FG_BLACK}
            # verbose message type string
            MSG_TYPE_VERBOSE="[ Warning ]"
            ;;

        *)                                          #   Unknown
            COLOR_FG_ONLY=${NORMAL}
            COLOR_FB_AND_BG=${NORMAL}
            # verbose message type string
            MSG_TYPE_VERBOSE="[ Unknown ]"
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


    # coLogCat output
    #printf " $cMSG_TYPE_LONG $DATE $TIME $cMSG_TYPE_SHORT $PROCESS_ID\t $THREAD_ID\t $cMSG_SOURCE $MSG\n"
    printf " $COLOR_FG_ONLY $MSG_TYPE_VERBOSE ${NORMAL} $DATE $TIME $COLOR_FB_AND_BG $MSG_TYPE ${NORMAL} $PROCESS_ID\t $THREAD_ID\t $COLOR_FG_ONLY $MSG_SOURCE ${NORMAL} $MSG\n"
}



# ----------------------------------------------------------------------------------------------------------------------------
# START ADBLOGCAT
# ----------------------------------------------------------------------------------------------------------------------------
function startADBLogcat() {
    printf "\nTrying to start logcat using: $ADB_LOGCAT_COMMAND\n"

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

# validate parameters
printf "Checking parameters\n"
for CURRENT_PARAMETER in "$@"
do
    case "$CURRENT_PARAMETER" in
        "-h" | "--help")
            printf " ${FG_GREEN}[   OK   ]${NORMAL}\tRequesting help\n"
            displayHelp
            ;;
         "-f" | "--filter")
            setLogCatLevel
            ;;
        *)
            printf " ${FG_RED}[  FAIL  ]${NORMAL}\tUnsupported parameter '$CURRENT_PARAMETER'\n\n"
            ;;
    esac
done
printf " ${FG_GREEN}[   OK   ]${NORMAL}\tFinished checking parameters\n\n"

startADBLogcat
