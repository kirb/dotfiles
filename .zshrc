#!/usr/bin/env zsh

# == REQUIRES: ==
# git clone --recursive https://github.com/kirb/dotfiles.git ~/.dotfiles
# ln -s .dotfiles/.zshrc ~/.zshrc
# brew tap homebrew/command-not-found
# brew install zsh-syntax-highlighting
# iTerm2 –> Install Shell Integration

# path yo
[[ -z "$THEOS" ]] && export THEOS=~/theos

export PATH=$HOME/.dotfiles/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.rvm/bin
export MANPATH=/usr/local/share/man:$MANPATH

# force terminal type
export TERM=xterm-256color

# language
export LANG=en_AU.UTF-8 LC_CTYPE=en_AU.UTF-8

# tmux
if [[ ! -z "$SSH_CLIENT" && -z "$TMUX" ]]; then
	tmux attach || tmux
fi

# oh my zsh
ZSH_THEME=kirb-powerlevel
DISABLE_AUTO_UPDATE=true
COMPLETION_WAITING_DOTS=true
ENABLE_CORRECTION=true
DEFAULT_USER=kirb
plugins=(battery brew gpg-agent osx pod safe-paste ssh-agent tmux)

ZSH=$(dirname $0)/.oh-my-zsh

source $ZSH/oh-my-zsh.sh

# important functions
has() {
	type "$1" >/dev/null 2>/dev/null
}

safe_source() {
	[[ -f "$1" ]] && source "$1"
}

# exports
export PROJ=~/Documents/Projects
export THEOS_DEVICE_IP=local
export SDKVERSION= SIMVERSION=

export EDITOR='code -wr'

# if this is an ssh session, use nano instead
[[ ! -z "$SSH_CLIENT" ]] && export EDITOR=nano

export PERL_MB_OPT="--install_base \"$HOME/.perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
export GOPATH=/usr/local/lib/go

# fix for homebrew zsh
# see `brew info zsh`
if [[ "$SHELL" != "/usr/bin/zsh" ]] && has brew; then
	unalias run-help 2>/dev/null
	autoload run-help
	HELPDIR=/usr/local/share/zsh/help
fi

# additional stuff
safe_source $(dirname $0)/.aliases
safe_source $(dirname $0)/.functions
safe_source ~/.iterm2_shell_integration.zsh

# this must be sourced last
safe_source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
