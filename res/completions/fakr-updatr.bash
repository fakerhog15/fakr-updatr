_fakr-updatr() {
	local arg="${2}"
	local -a opts
	opts=('-c --check
	       -l --list
	       -s --services
	       -D --debug
	       --gen-config
	       --show-config
	       --edit-config
	       --tray
	       -h --help
	       -V --version')

	COMPREPLY=( $(compgen -W "${opts[*]}" -- "${arg}") )
}

complete -F _fakr-updatr fakr-updatr
