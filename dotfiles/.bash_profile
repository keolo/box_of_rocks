# Bash Profile OS X
# -----------------
# Keolo Keagy

# Comand prompt formatting
#-------------------------
NO_COLOR="\[\033[0m\]"
RED="\[\033[0;31m\]"
LIGHT_RED="\[\033[1;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[1;37m\]"

# Display title bar if login shell is xterm
case $TERM in
    xterm*)
        TITLEBAR='\[\e]2;\u@\h \w\a\]'
        ;;
    *)
        TITLEBAR=""
        ;;
esac

PS1="${TITLEBAR}\
$CYAN>$NO_COLOR "


# Misc
#-----

# Default editor
export EDITOR='vi'

# Set editing mode
set -o emacs

# Path
PATH=$PATH:~/bin:~/repos/box_of_rocks
export PATH

# cd Path
CDPATH=.:~:~/Sites
export CDPATH

##
# Tips and Tricks... from http://www.caliban.org/bash/index.shtml
# HISTIGNORE="&:l:ls:ls *:l *:cd:cd *:[bf]g:exit:quit:q:sleep *"
        # History ignores commands that include any l/ls/cd etc
        # This kicks-ass! It drops repeats and other useless
        # things from the command history!
HISTIGNORE="ls:cd:[bf]g:exit:quit:q:sleep *:ssh *:say*"
        # I want to see cd * in my history
HISTCONTROL=ignoreboth
        # ignores both commands that start with a space or a tab, and duplicates
        # other options are as follows:
        # `ignorespace' means to not enter lines which begin with a space or tab into the history list.
        # `ignoredups' means to not enter lines which match the last entered line.
        # `ignoreboth' combines the two options.
HISTFILESIZE=1000000000
HISTSIZE=1000000

export HISTIGNORE
export HISTCONRTOL
export HISTFILESIZE
export HISTSIZE


# Aliases
#--------

# Bash
alias bashprofile='vi ~/.bash_profile && source ~/.bash_profile'
alias ll='ls -laF'

# MySQL
alias mysql_start='/Library/StartupItems/MySQLCOM/MySQLCOM start'
alias mysql_stop='/Library/StartupItems/MySQLCOM/MySQLCOM stop'
alias mysql_restart='/Library/StartupItems/MySQLCOM/MySQLCOM restart'

# TextMate
# Open only common directories in a rails app
alias matey='mate app config lib db public test vendor/plugins &'

# Rails
alias ss='script/server'
alias sc='script/console'
alias sg='script/generate'
alias sp='script/plugin'

# Ruby (make sure you have qri installed)
alias ri='qri'

# Git
alias ga='git add'
alias gco='git checkout'
alias gc='git commit -v'
alias gb='git branch'
alias gba='git branch -a'
alias gd='git diff | mate'
alias gl='git log'
alias gpl='git pull'
alias gp='git push'
alias gst='git status'
alias gw='git whatchanged'
alias gr='git rebase'

# Copy public ssh key to remote host
# Usage: authme username@host.com
function authme {
  ssh $1 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
}

