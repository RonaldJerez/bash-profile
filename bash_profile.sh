#!/bin/bash
# bash profile created by Ronald Jerez (github.com/ronaldjerez)

# Regular colors
BLACK="\e[0;30m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
MAGENTA="\e[0;35m"
CYAN="\e[0;36m"
GRAY="\e[0;37m"
WHITE="\e[0;97m"
CLEAR="\e[0m"

# source in git completion and git prompt
source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash

if [[ $MACHTYPE =~ apple ]]; then
	# OSX specific
	export LSCOLORS='dxgxExgxbxDgDdabagacad'
else
	# nix specific
	export LSCOLORS='di=33:ln=36:fi=0:pi=36:ex=32:so=1;35:bd=01;33:cd=01;33:or=37:mi=37'
fi

# Change the command line style
# get the user display name rather than handle
USERNAME=$(finger $USER | head -1 | cut -d : -f 3)
PROMPT_COMMAND='__git_ps1 "\\n$CYAN# $USERNAME [\T] $YELLOW\w/$CLEAR" "\\n"'

# some handy history control
export HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="$YELLOW%h %d %H:%M:%S > $CLEAR"
export HISTIGNORE="ls*:cd*:echo*"
alias h='history | grep'

# use sublime to edit files
if hash sublime 2>/dev/null; then
	alias edit='sublime'
fi

# setup nvm if available
if [ -d $HOME/.nvm ]; then
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# ignore case for auto complete
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# some handy alias
alias ls='ls -Glhp'
alias gp='git pull'
alias gf='git fetch -p'
alias gc='git checkout'
alias gclean='git fetch -p && git branch | grep -Ev "master|dev" | xargs git branch -D'

# export a variable so we dont re-setup the profile
export _COMMON_PROFILE_SET_=1
