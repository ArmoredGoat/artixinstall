#
# ~/.bash_aliases
#

# G I T
alias gs='git status'           # View Git status
alias ga='git add'              # Add a file to Git
alias gaa='git add --all'       # Add all files to Git
alias gc='git commit'           # Commit changes to code
alias gl='git log --oneline'    # View Git log
alias gb='git checkout -b'      # Create new Git branch and move to new branch
alias gd='git diff'             # View difference

# Q O L
alias cd..='cd ..'              # Get rid of command not found
alias ..='cd ..;pwd'            # Move to parent folder
alias ...='cd ../..;pwd'        # Move up two parent folders
alias ....='cd ../../..;pwd'    # Move up three parent folders
alias .....='cd ../../../../'   # Move up four parent folders
alias .4='cd ../../../../'      # Move up four parent folders
alias .5='cd ../../../../..'    # Move up five parent folders

alias shutdown='sudo openrc-shutdown -p now'    # Shorter shutdown command
alias reboot='sudo reboot'                      # Shorter reboot command
alias update='sudo pacman -Syu'                 # Shorter update command

alias c='clear'                     # Clear termninal screen
alias h='history'                   # View bash history
alias j='jobs -l'                   # View running jobs
alias tree='tree --dirsfirst -F'    # Display direcotry structure
alias mkdir='mkdir -pv'             # Make directory and parent directories with verbosity

alias ls='ls --color=auto'          # Colorize ls output
alias ll='ls -la'                   # Use long listing format
alias l.='ls -d .* --color=auto'    # Show hidden files

# Colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias bc='bc -l'    # Start calculator with math support

alias mount='mount | column -t'  # Make mount command output pretty and human readable format

alias now='date +"%T"'              # Show current time
alias nowtime=now                   # Different command to show time
alias nowdate='date +"%Y/%m/%d"'    # Show current date

alias ping='ping -c 5'              # Stop after sending five packets
alias fastping='ping -c 100 -s.2'   # Do not wait interval 1 second, go fast

alias ports='netstat -tulanp'       # Show open ports

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