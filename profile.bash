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

# TODO include own git completion file instead of relying on xcode
GIT_COMPLETION_FILE=/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash

# function to style console output
# you can combine, color, style, or make color lighther
# combining of format (bold/underline etc) is not supported
#
# Usage:
# style red "some text"
# style light red "some text"
# style bold yellow "something else"
# style underline light green "green text"
style() {
	local format=0
	local light=0

	while [ $# -gt 2 ]; do
		case "$1" in
			light)		light=1 ;;
			bold)		format=1 ;;
			underline)	format=4 ;;
			blink)		format=5 ;;
			invert)		format=7 ;;
			hidden)		format=8 ;;
		esac
		shift
	done

	local color=$(echo "$1" | tr '[:lower:]' '[:upper:]') #convert color name to upper
	local code="${!color}" # get the code of the color via expansion

	(($light)) && code=${code/3/9}
	(($format)) && code=${code/0/$format}

	printf "$code" # print the style code
	[ -n "$2" ] && printf "$2$CLEAR" # print text if available
}

# git status information based on
# https://github.com/necolas/dotfiles/blob/master/shell/bash_prompt
prompt_git() {
	local s=""
	local branchName=""
	local remoteBranchName=""

	local CLEAN_COLOR=${GIT_PROMPT_CLEAN_COLOR:-"green"}
	local DIRTY_COLOR=${GIT_PROMPT_DIRTY_COLOR:-"red"}
	local AHEAD_COLOR=${GIT_PROMPT_AHEAD_COLOR:-"light cyan"}
	local BEHIND_COLOR=${GIT_PROMPT_BEHIND_COLOR:-"light black"}

	# lets assume clean
	local color=$CLEAN_COLOR

	# check if the current directory is in a git repository
	if [ $(git rev-parse --is-inside-work-tree &>/dev/null; printf "%s" $?) == 0 ]; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "false" ]; then

			# ensure index is up to date
			git update-index --really-refresh -q &>/dev/null

			if [[ -n $GIT_PROMPT_SHOW_DIRTY ]]; then
				# check for uncommitted changes in the index
				if ! $(git diff --quiet --ignore-submodules --cached); then
					s="$s+"
					color=$DIRTY_COLOR
				fi

				# check for unstaged changes
				if ! $(git diff-files --quiet --ignore-submodules --); then
					s="$s!"
					color=$DIRTY_COLOR
				fi

				# check for untracked files
				if [ -n "$(git ls-files --others --exclude-standard)" ]; then
					s="$s?"
					color=$DIRTY_COLOR
				fi
			fi

			# check for stashed files
			if [[ -n $GIT_PROMPT_SHOW_STASH && -n $(git rev-parse --verify refs/stash 2>/dev/null) ]]; then
				s="$s$"
			fi

			# # check weather we are ahead or behind remote branch
			if [[ -n $GIT_PROMPT_SHOW_BEHIND || -n $GIT_PROMPT_SHOW_AHEAD ]]; then
				remoteBranchName="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)"
				remoteBranchName="${remoteBranchName/'@{u}'/}"

				if [[ -n $remoteBranchName ]]; then
					if [[ -n $GIT_PROMPT_SHOW_AHEAD && $(git rev-list --count --left-only HEAD...$remoteBranchName) > 0 ]]; then
						color=$AHEAD_COLOR
					fi

					if [[ -n $GIT_PROMPT_SHOW_BEHIND && $(git rev-list --count --right-only HEAD...$remoteBranchName) > 0 ]]; then
						color=$BEHIND_COLOR
					fi
				fi
			fi

		fi

		# get the short symbolic ref
		# if HEAD isn't a symbolic ref, get the short SHA
		# otherwise, just give up
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
					  git rev-parse --short HEAD 2> /dev/null || \
					  printf "(unknown)")"

		[ -n "$s" ] && s=" [$s]"

		#printf " on "
		style $color " @$branchName$s"
	else
		return
	fi
}

# when running NVM check to see if we are changing to a different version
# and update the variable NODE_VERSION on this script for prompt purposes
nvm_padded() {
	if [[ $1 == 'use' || $1 == 'install' ]]; then
		nvm $@ && get_node_version
	else
		nvm $@
	fi
}

# gets the currrent version of node and stores it on a global variable
get_node_version() {
   NODE_VERSION=$(node -v)
}

# if we are tyring to open a directory open it on a new editor
# otherwise open a file in an existing editor
open_code() {
	if [ "$#" -eq 1 ] && [ -f $1 ]; then
		code -r $1
	else
		code $@
	fi
}

# source in git completion
if [ -f $GIT_COMPLETION_FILE ]; then
	source $GIT_COMPLETION_FILE
fi

# get the user display name rather than handle
USERNAME=$(finger $USER | head -1 | cut -d : -f 3)

# Change the command line style
_PS1='\n$(style light black "#$USERNAME [\T] "; style cyan "\w"; prompt_git)'

if [[ -n $SHOW_NODE_VERSION ]]; then
	get_node_version
	alias nvm=nvm_padded

	_PS1="$_PS1 $(style green '⬢ ${NODE_VERSION:1}')"
fi

_PS1="$_PS1\n"
export PS1=$_PS1

# some handy history control
export HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="$(style green)%h %d %H:%M:%S > $(style clear)"
export HISTIGNORE="ls*:cd*:echo*:man*:h *:clear"
alias h='history | grep'

# if code is installed, set it to open files in existing windows, and only open directories in new windows
if hash code 2>/dev/null; then
	alias code=open_code
	alias edit=open_code
fi

# ignore case for auto complete
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# fancy ls
if [[ $MACHTYPE =~ apple ]]; then
	# OSX specific
	 _LSCOLORS='GxFxCxDxBxegedabagaced'
else
	# nix specific
	_LSCOLORS='di=33:ln=36:fi=0:pi=36:ex=32:so=1;35:bd=01;33:cd=01;33:or=37:mi=37'
fi

# run ls right after cd
cs() { cd "$1" && ls -alhG; }

export CLICOLOR=1
export LSCOLORS=$_LSCOLORS
alias ls='ls -alhG'
alias ..='cd ..'
alias ...='cd ../..'
alias cd="cs"

# removes all branches except for dev and master from local, and cleans remote references
alias gclean='git fetch -p && git branch | grep -Ev "master|dev" | xargs -p git branch -d'

# removes branches in local that are also gone in remote, and cleans remote references
alias gprune='git fetch -p && git branch -vv | grep ": gone" | awk '\''{print $1}'\'' | xargs -p git branch -d'

# amend the last commit with current changes and update the author/date info
alias gamend='git commit --amend --no-edit --reset-author'

# install GEMs and NPM packages locally so we dont need to use sudo
export GEM_HOME=$HOME/.gem
export NPM_PACKAGES=$HOME/.npm-packages
export PATH="$GEM_HOME/bin:$NPM_PACKAGES/bin:$PATH"

# export a variable so we dont re-setup the profile
export _COMMON_PROFILE_SET_=1
