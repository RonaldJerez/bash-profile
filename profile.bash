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

		[ -n "$s" ] && s="[$s]"

		printf " on "
		style $color "$branchName $s"
	else
		return
	fi
}

# source in git completion
# TODO include own git completion file instead of relying on xcode
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
#PROMPT_COMMAND='__git_ps1 "\\n$CYAN#$USERNAME [\T] $YELLOW\w$CLEAR" "\\n" " | %s "'
export PS1='\n$(style cyan "#$USERNAME [\T] "; style yellow "\w"; prompt_git)\n'

# some handy history control
export HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="$(style green)%h %d %H:%M:%S > $(style clear)"
export HISTIGNORE="ls*:cd*:echo*"
alias h='history | grep'

# use sublime to edit files if its available, must create a link to sublime cli first
# ln -s  "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/sublime
if hash sublime 2>/dev/null; then
	alias edit='sublime'
fi

# ignore case for auto complete
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# some handy alias
alias ls='ls -Glhp'
alias gp='git pull'
alias gf='git fetch -p'
alias go='git checkout'
alias ga='git add'
alias gc='git commit'
alias gclean='git fetch -p && git branch | grep -Ev "master|dev" | xargs git branch -D'

# export a variable so we dont re-setup the profile
export _COMMON_PROFILE_SET_=1
