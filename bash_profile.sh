#!/bin/bash
# bash profile created by Ronald Jerez (e052007)

style() {
	local black=30
	local red=31
	local green=32
	local yellow=33
	local blue=34
	local purple=35
	local cyan=36
	local white=37
	local dark_grey=90
	local light_red=91
	local light_green=92
	local light_yellow=93
	local light_blue=94
	local light_purple=95
	local turq=96
	local none=0
	
	# the choosen one
	local color="$1"

	# if nothing is passed in reset the color
	if [ -z "$1" ]; then color="none"; fi
	
	# starting block
	printf "\033["
	
	# bold ? 
	if [ "$3" == "bold" ]; then
		printf "1;"
	fi
	
	# the actual color code
	printf "${!color}m"
	
	# some text passed in
	if [ -n "$2" ]; then
		printf "$2\033[m"
	fi
}
export -f style

# get git branch if this directory is a git repository
# https://gist.github.com/clozed2u/4971506
git_branch() {
	# get git branch
	local branch=$(git symbolic-ref --short HEAD 2>/dev/null)

	if [ -n "$branch" ]; then		
		local stat=$(git status 2>&1)
		
		if [[ "$stat" != *'working directory clean'* ]]; then
			style red " [$branch]"
		elif [[ "$stat" == *'Your branch is ahead'* ]]; then
			style yellow " [$branch]"
		elif [[ "$stat" == *'Your branch is behind'* ]]; then
			style dark_grey " [$branch]"
		else
			style cyan " [$branch]"
		fi
	fi
}

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# some handy alias
alias ls='ls -Glhp'
alias h='history | grep'
alias edit='sublime'

if [[ $MACHTYPE =~ apple ]]; then
	# OSX specific
	export LSCOLORS='dxgxExgxbxDgDdabagacad'
else
	# nix specific
	export LSCOLORS='di=33:ln=36:fi=0:pi=36:ex=32:so=1;35:bd=01;33:cd=01;33:or=37:mi=37'
fi

# save user name for PS1
USERNAME=$(finger $USER | head -1 | cut -d : -f 3)

# Change the command line style
export PS1='\n$(style green "#$USERNAME [\T] \w/"; git_branch)\n'

export HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="$(style yellow)%h %d %H:%M:%S > $(style none)"
# export HISTIGNORE="ls*:cd*:echo*"

# export a variable so we dont re-setup the profile
export _COMMON_PROFILE_SET_=1
