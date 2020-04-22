#!/usr/bin/env zsh

# == REQUIRES: ==
# git clone --recursive https://github.com/kirb/dotfiles.git ~/.dotfiles
# ln -s .dotfiles/.zshrc ~/.zshrc
# brew install zsh-syntax-highlighting
# iTerm2 –> Install Shell Integration

# path yo
[[ -z $THEOS ]] && export THEOS=~/theos

export PATH=$HOME/.local/bin:$HOME/.dotfiles/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/snap/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.rvm/bin
export MANPATH=/usr/local/share/man:$MANPATH

if [[ -z $LANG || -z $LC_CTYPE ]]; then
	export LANG=en_AU.UTF-8 LC_CTYPE=en_AU.UTF-8
fi

# launch tmux now if in root tty of an SSH session
if [[ ! -z $SSH_CLIENT && -z $TMUX ]]; then
	[[ $LC_TERMINAL == iTerm ]] && TMUX_CC_FLAG=-CC
	tmux -f ~/.dotfiles/tmux.conf $TMUX_CC_FLAG attach
fi

ZSH=$(dirname $0)/stuff/oh-my-zsh
source $ZSH/plugins/ssh-agent/ssh-agent.plugin.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh my zsh
ZSH_THEME=kirb-powerlevel
DISABLE_AUTO_UPDATE=true
COMPLETION_WAITING_DOTS=true
ENABLE_CORRECTION=true
DEFAULT_USER=kirb
ZSH_WAKATIME_PROJECT_DETECTION=true
plugins=(adb brew gpg-agent osx pod safe-paste zsh-wakatime)

source $ZSH/oh-my-zsh.sh

# important functions
has() {
	type "$1" >/dev/null 2>/dev/null
}

safe_source() {
	[[ -f $1 ]] && source "$1"
}

# exports
export PROJ=~/Documents/Projects
export THEOS_DEVICE_IP=local
export SDKVERSION= SIMVERSION=

export EDITOR='code -wr'

# if this is an ssh session, use nano instead
[[ ! -z $SSH_CLIENT ]] && export EDITOR=nano

export PERL_MB_OPT="--install_base \"$HOME/.perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
export GOPATH=/usr/local/lib/go

# well intentioned feature, but god it’s annoying. sorry
export HOMEBREW_NO_AUTO_UPDATE=1

# super useful for those `rm -r $DERIVED_DATA` moments
export DERIVED_DATA=~/Library/Developer/Xcode/DerivedData

# fix for homebrew zsh
# see `brew info zsh`
if [[ $SHELL != /usr/bin/zsh ]] && has brew; then
	unalias run-help 2>/dev/null
	autoload run-help
	HELPDIR=/usr/local/share/zsh/help
fi

# additional stuff
safe_source $(dirname $0)/zsh-aliases
safe_source $(dirname $0)/zsh-functions
# safe_source ~/.iterm2_shell_integration.zsh

# this must be sourced last
safe_source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
