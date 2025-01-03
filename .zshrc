#!/usr/bin/env zsh

# == REQUIRES: ==
# git clone --recursive https://github.com/kirb/dotfiles.git ~/.dotfiles
# echo 'source ~/.dotfiles/.zshrc' >> ~/.zshrc
# sudo apt install zsh-syntax-highlighting zsh-autosuggestions
# iTerm2 –> Install Shell Integration

# Important functions
has() {
	(( $+commands[$1] ))
}

safe_source() {
	if [[ -f $1 ]]; then
		source "$1"
	fi
}

# path yo
DOTFILES=${0:h:A}
[[ $DOTFILES == $HOME ]] && DOTFILES=$HOME/.dotfiles
path=($HOME/.local/bin $DOTFILES/bin $path /sbin /usr/local/bin /usr/sbin /usr/local/sbin)

export LANG=${LANG:-en_US.UTF-8}
export LC_CTYPE=${LC_CTYPE:-$LANG}

PACKAGE_MANAGER=/usr
if [[ -d /opt/homebrew ]]; then
	# ARM Homebrew, because, I don’t even know why
	PACKAGE_MANAGER=/opt/homebrew
	path=(/opt/homebrew/bin $path)
	manpath=(/opt/homebrew/share/man $manpath)
fi

# Da Procursus
if [[ -d /opt/procursus ]]; then
	PACKAGE_MANAGER=/opt/procursus
	path=(/opt/procursus/bin $path)
	manpath=(/opt/procursus/share/man $manpath)
fi

# Ruby
if has ruby && has gem; then
	path+=($(ruby -r rubygems -e 'puts Gem.user_dir')/bin)
fi

# pnpm
if has pnpm; then
	export PNPM_HOME=$HOME/.local/share/pnpm
	[[ $VENDOR == apple ]] && PNPM_HOME=$HOME/Library/pnpm
	path+=($PNPM_HOME)
fi

# krew
if [[ -d ~/.krew ]]; then
	export KREW_ROOT=$HOME/.krew
	path+=($KREW_ROOT/bin)
fi

# Fix ghostty terminfo (for now)
if [[ $TERM == xterm-ghostty && ! -d $TERMINFO ]]; then
	TERM=xterm-256color
	export TERM_PROGRAM=ghostty LC_TERMINAL=ghostty
fi

# Launch tmux now if in root tty of an SSH session
if [[ ! -z $SSH_CLIENT && -z $TMUX && -z $VSCODE_SHELL_INTEGRATION ]] && has tmux; then
	[[ $LC_TERMINAL == iTerm2 ]] && TMUX_CC_FLAG=-CC
	tmux -2f ~/.dotfiles/.tmux.conf $TMUX_CC_FLAG attach
fi

# Fix tmux 256 color
[[ ! -z $TMUX && $TERM == screen ]] && TERM=screen-256color

# Check for IntelliJ’s printenv command because anything interactive/blocking will break it
# detecting environment at startup.
# https://youtrack.jetbrains.com/articles/IDEA-A-19/Shell-Environment-Loading
[[ ! -z $INTELLIJ_ENVIRONMENT_READER ]] && NOT_ACTUALLY_INTERACTIVE=1

# Do this before we source instant prompt, because it might interactively prompt for passphrase
ZSH=$DOTFILES/stuff/oh-my-zsh
ZSH_CUSTOM=$DOTFILES/oh-my-zsh/custom
[[ -z $NOT_ACTUALLY_INTERACTIVE && $VENDOR != apple ]] && source $ZSH_CUSTOM/plugins/ssh-agent/ssh-agent.plugin.zsh

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
plugins=(command-not-found git gitfast safe-paste zsh-interactive-cd)
has bundler && plugins+=(bundler)
has gpgconf && plugins+=(gpg-agent)
has hub     && plugins+=(github)
has pip     && plugins+=(pip)
has repo    && plugins+=(repo)
has ripgrep && plugins+=(ripgrep)
has swift   && plugins+=(swiftpm)
has ufw     && plugins+=(ufw)
[[ $VENDOR == apple ]] && plugins+=(brew macos pod)
source $ZSH/oh-my-zsh.sh

# Exports
export EDITOR='code -wr'
[[ ! -z $SSH_CLIENT ]] && export EDITOR=nano

export THEOS=~/theos
export THEOS_DEVICE_IP=local

export PERL_MB_OPT="--install_base \"$HOME/.perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5"

export GOPATH=$HOME/go

export HOMEBREW_NO_AUTO_UPDATE=1

export FZF_DEFAULT_COMMAND=fd

export BAT_THEME=ansi

TIMEFMT='[time] %J  elapsed: %*E, cpu: %P, max mem: %M kB, swapped: %W, signals: %k, msg rx: %r, msg tx: %s'

# Additional stuff
safe_source $DOTFILES/zsh-aliases
safe_source $DOTFILES/zsh-functions

# This must be sourced last
safe_source $PACKAGE_MANAGER/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
safe_source $PACKAGE_MANAGER/share/zsh-autosuggestions/zsh-autosuggestions.zsh
