typeset _agent_forwarding _ssh_env_cache

function _start_agent() {
	local lifetime
	zstyle -s :omz:plugins:ssh-agent lifetime lifetime

	# start ssh-agent and setup environment
	/usr/bin/ssh-agent -s ${lifetime:+-t} ${lifetime} | sed 's/^echo/#echo/' >! $_ssh_env_cache
	chmod 600 $_ssh_env_cache
	. $_ssh_env_cache > /dev/null
}

function _add_identities() {
	local id line lines
	local -a identities loaded_ids not_loaded
	zstyle -a :omz:plugins:ssh-agent identities identities

	# check for .ssh folder presence
	if [[ ! -d $HOME/.ssh ]]; then
		return
	fi

	# add default keys if no identities were set up via zstyle
	# this is to mimic the call to ssh-add with no identities
	if [[ ${#identities} -eq 0 ]]; then
		# key list found on `ssh-add` man page's DESCRIPTION section
		for id in id_rsa id_dsa id_ecdsa id_ed25519 identity; do
			# check if file exists
			[[ -f $HOME/.ssh/$id ]] && identities+=$id
		done
	fi

	# get list of loaded identities' signatures and filenames
	if lines=$(/usr/bin/ssh-add -l); then
		for line in ${(f)lines}; do
			loaded_ids+=${${(z)line}[3]}
		done
	fi

	# add identities if not already loaded
	for id in $identities; do
		# check for filename match, otherwise try for signature match
		if [[ ${loaded_ids[(I)$HOME/.ssh/$id]} -le 0 ]]; then
			not_loaded+=$HOME/.ssh/$id
		fi
	done

	if [[ -n $not_loaded ]]; then
		if [[ $VENDOR == apple ]]; then
			export APPLE_SSH_ADD_BEHAVIOR=macos
			flags=-qAK
			alias ssh-add="ssh-add -AK"
		fi
		/usr/bin/ssh-add $flags ${^not_loaded}
	fi
}

# Get the filename to store/lookup the environment from
_ssh_env_cache="$HOME/.ssh/environment-$SHORT_HOST"

# test if agent-forwarding is enabled
zstyle -b :omz:plugins:ssh-agent agent-forwarding _agent_forwarding

if [[ -z $SSH_AUTH_SOCK ]] && [[ $VENDOR != apple ]]; then
	if [[ $_agent_forwarding == "yes" && -n "$SSH_AUTH_SOCK" ]]; then
		# Add a nifty symlink for screen/tmux if agent forwarding
		[[ -L $SSH_AUTH_SOCK ]] || ln -sf "$SSH_AUTH_SOCK" /tmp/ssh-agent-$USER-screen
	elif [[ -f "$_ssh_env_cache" ]]; then
		# Source SSH settings, if applicable
		. $_ssh_env_cache > /dev/null
		if ! pgrep -U $UID ssh-agent | command grep -q $SSH_AGENT_PID; then
			_start_agent
		fi
	else
		_start_agent
	fi

	_add_identities
fi

# tidy up after ourselves
unset _agent_forwarding _ssh_env_cache
unfunction _start_agent _add_identities
