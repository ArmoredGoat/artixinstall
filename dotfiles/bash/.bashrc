#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

##########  PATH

# Add local 'pip' to PATH
export PATH="${PATH}:${HOME}/.local/bin"

##########  VARIABLES

export EDITOR=nvim
export VISUAL=nvim

#####   HISTORY CUSTOMIZATION   #####

HISTFILE=~/.bash_history.$HOSTNAME  # Guard history getting truncated to default 500 lines if bash --norc is run
HISTTIMEFORMAT="%F %T "             # Add date and time formatting to bash history
HISTCONTROL=ignoredups              # Ignore duplicate commands in bash history
HISTSIZE=-1                         # Disable command limit of bash history
HISTFILESIZE=-1                     # Disable size limit of bash history file

shopt -s histappend             # Set bash history to append instead of overwriting

#####   BASH CUSTOMIZATION  #####

blk='\[\033[01;30m\]'   # Black
blu='\[\033[01;34m\]'   # Blue
cyn='\[\033[01;36m\]'   # Cyan
grn='\[\033[01;32m\]'   # Green
mag='\[\033[01;35m\]'   # Magenta
red='\[\033[01;31m\]'   # Red
wht='\[\033[01;37m\]'   # White
ylw='\[\033[01;33m\]'   # Yellow

clr='\[\033[00m\]'      # Reset

#####	PROMPT CUSTOMIZATION	#####

function nonzero_return() {
	RETVAL=$?
	[ $RETVAL -ne 0 ] && echo "─[$clr$RETVAL$cyn]"
}

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "─[$clr${BRANCH}${STAT}$cyn]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

export PS1="$cyn┌──[$ylw\u$cyn@$ylw\h$cyn]─[$clr\w$cyn]$(parse_git_branch)$(nonzero_return)\n└─$ "


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
    fastfetch
fi

# Import colorscheme from 'wal' asynchronously
# & 	-> Run the process in the background.
# ( ) 	-> Hide shell job control messages.
(cat ~/.cache/wal/sequences &)

# Also change colorscheme of TTYs.
source ~/.cache/wal/colors-tty.sh