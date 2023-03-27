#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#####   HISTORY CUSTOMIZATION   #####

export HISTTIMEFORMAT="%F %T "  # Add date and time formatting to bash history
export HISTCONTROL=ignoredups   # Ignore duplicate commands in bash history
export HISTSIZE=-1              # Disable command limit of bash history
export HISTFILESIZE=-1          # Disable size limit of bash history file

shopt -s histappend             # Set bash history to append instead of overwriting

#####   BASH CUSTOMIZATION  #####

blk='\[\033[01;30m\]'   # Black
red='\[\033[01;31m\]'   # Red
grn='\[\033[01;32m\]'   # Green
ylw='\[\033[01;33m\]'   # Yellow
blu='\[\033[01;34m\]'   # Blue
pur='\[\033[01;35m\]'   # Purple
cyn='\[\033[01;36m\]'   # Cyan
wht='\[\033[01;37m\]'   # White
clr='\[\033[00m\]'      # Reset

#####   VIM CUSTOMIZATION   #####

set -o vi   # Enable vim commands in command line

#####   LOAD ALIASES        #####

if [ -f $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi


##### GENERAL CUSTOMIZATION #####
# Check, if other terminal windows are currently open. If not, run neofetch
# This prevents neofetch from launching everytime you open a terminal
runningTerms=$(ps a | awk '{print $2}' | grep -vi "tty*" | uniq | wc -l);
if [ $runningTerms -eq 1 ]; then
     neofetch
fi