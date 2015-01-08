function help {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	echo "jqnpm: npm style package manager for jq"
	echo "https://github.com/joelpurra/jqnpm"
	echo
	echo "jqnpm <action> [options]"
	echo
	echo "Actions"
	echo "  help"
	echo "    Show this help."
	echo
	echo "  initialize"
	echo "    Create default jq.json and jq/main.jq files."
	echo
	echo "  fetch [package]"
	echo "    Preload package cache from remote server."
	echo
	echo "  install [package]"
	echo "    Install/add jq.json dependencies to the current directory."
	echo
	echo "  execute [flags for jq]"
	echo "    Run normal jq with dependencies. **This is a workaround until plain jq is up to speed.**"
}
