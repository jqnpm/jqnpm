function help {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	echo "jqnpm: npm style package manager for jq"
	echo "https://github.com/joelpurra/jqnpm"
	echo
	echo "jqnpm <action> [options]"
	echo
	echo "Actions"
	echo "  help                      Show this help."
	echo "  initialize                Create default jq.json and jq/main.jq files."
	echo "  fetch [package]           Preload package cache from remote server."
	echo "  install [package]         Install/add jq.json dependencies to the current directory."
	echo "  execute [flags for jq]    Run normal jq with dependencies. **This is a workaround until plain jq is up to speed.**"
}
