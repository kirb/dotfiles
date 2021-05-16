#!/usr/bin/env zsh

# == REQUIRES: ==
# git clone --recursive https://github.com/kirb/dotfiles.git ~/.dotfiles
# echo 'source ~/.dotfiles/.zshrc' >> ~/.zshrc
# sudo apt install zsh-syntax-highlighting zsh-autosuggestions
# iTerm2 –> Install Shell Integration

# Important functions
has() {
	[[ $+commands[$1] == 1 ]]
}

safe_source() {
	if [[ -f $1 ]]; then
		source "$1"
	fi
}

# path yo
PATH=$HOME/.local/bin:$HOME/.dotfiles/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

if [[ -z $LANG || -z $LC_CTYPE ]]; then
	export LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
fi

PACKAGE_MANAGER=/usr
if [[ -d /opt/homebrew ]]; then
	# ARM Homebrew, because, I don’t even know why
	PACKAGE_MANAGER=/opt/homebrew
	PATH=/opt/homebrew/bin:$PATH
	MANPATH=/opt/homebrew/share/man:$MANPATH
elif [[ -d /usr/local/Library/Homebrew ]]; then
	# x86 Homebrew, which to be fair, I don’t even know why either
	PACKAGE_MANAGER=/usr/local
	MANPATH=/usr/local/share/man:$MANPATH
fi

# Da Procursus
if [[ -d /opt/procursus ]]; then
	PACKAGE_MANAGER=/opt/procursus
	PATH=/opt/procursus/bin:$PATH
	MANPATH=/opt/procursus/share/man:$MANPATH
fi

if has ruby && has gem; then
	PATH+=:$(ruby -r rubygems -e 'puts Gem.user_dir')/bin
fi

# Launch tmux now if in root tty of an SSH session
if [[ ! -z $SSH_CLIENT && -z $TMUX ]] && has tmux; then
	[[ $LC_TERMINAL == iTerm2 ]] && TMUX_CC_FLAG=-CC
	tmux -2f ~/.dotfiles/.tmux.conf $TMUX_CC_FLAG attach
fi

# Fix tmux 256 color
[[ ! -z $TMUX && $TERM == screen ]] && TERM=screen-256color

# Do this before we source instant prompt, because it might interactively prompt for passphrase
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
DEFAULT_USER=adamdemasi
plugins=(adb safe-paste)
has gpgconf              && plugins+=(gpg-agent)
[[ $VENDOR == apple ]]   && plugins+=(brew osx pod)
ZSH=$(dirname $0)/stuff/oh-my-zsh

source $ZSH/oh-my-zsh.sh

# Exports
export PROJ=~/Developer
export THEOS=~/theos
export THEOS_DEVICE_IP=local

export EDITOR='code -wr'
[[ ! -z $SSH_CLIENT ]] && export EDITOR=nano

export PERL_MB_OPT="--install_base \"$HOME/.perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"
export GOPATH=/usr/local/lib/go

export HOMEBREW_NO_AUTO_UPDATE=1

# Additional stuff
safe_source $(dirname $0)/zsh-aliases
safe_source $(dirname $0)/zsh-functions

# This must be sourced last
safe_source $PACKAGE_MANAGER/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source $PACKAGE_MANAGER/share/zsh-autosuggestions/zsh-autosuggestions.zsh
