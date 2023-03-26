#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ '

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

#####   ALIAS CUSTOMIZAZION #####

### GIT
alias gs='git status'           # View Git status
alias ga='git add'              # Add a file to Git
alias gaa='git add --all'       # Add all files to Git
alias gc='git commit'           # Commit changes to code
alias gl='git log --oneline'    # View Git log
alias gb='git checkout -b'      # Create new Git branch and move to new branch
alias gd='git diff'             # View difference

### QOL
alias ..='cd ..;pwd'            # Move to parent folder
alias ...='cd ../..;pwd'        # Move up two parent folders
alias ....='cd ../../..;pwd'    # Move up three parent folders

alias c='clear'                     # Clear termninal screen
alias h='history'                   # View bash history
alias tree='tree --dirsfirst -F'    # Display direcotry structure
alias mkdir='mkdir -p -v'           # Make directory and parent directories with verbosity

# View calender by typing first three letters of month
alias jan='cal 01 $(date +"%Y")'
alias feb='cal 02 $(date +"%Y")'
alias mar='cal 03 $(date +"%Y")'
alias apr='cal 04 $(date +"%Y")'
alias may='cal 05 $(date +"%Y")'
alias jun='cal 06 $(date +"%Y")'
alias jul='cal 07 $(date +"%Y")'
alias aug='cal 08 $(date +"%Y")'
alias sep='cal 09 $(date +"%Y")'
alias oct='cal 10 $(date +"%Y")'
alias nov='cal 11 $(date +"%Y")'
alias dec='cal 12 $(date +"%Y")'

alias shutdown='sudo openrc-shutdown -p now'
