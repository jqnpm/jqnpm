function help {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	echo "jqnpm: npm style package manager for jq"
	echo "${COLOR_WHITE}https://github.com/joelpurra/jqnpm${COLOR_NO_COLOR}"
	echo
	echo "jqnpm ${COLOR_WHITE}<action>${COLOR_NO_COLOR} [options]"
	echo
	echo "Actions:"
	echo "  ${COLOR_WHITE}help${COLOR_NO_COLOR}"
	echo "    Show this help."
	echo
	echo "  ${COLOR_WHITE}initialize${COLOR_NO_COLOR}"
	echo "    Create default jq.json and jq/main.jq files."
	echo
	echo "  ${COLOR_WHITE}fetch${COLOR_NO_COLOR} [package]"
	echo "    Preload package cache from remote server."
	echo
	echo "  ${COLOR_WHITE}install${COLOR_NO_COLOR} [package]"
	echo "    Install/add jq.json dependencies to the current directory."
	echo
	echo "  ${COLOR_WHITE}execute${COLOR_NO_COLOR} [flags for jq]"
	echo "    Run normal jq with dependencies. **This is a workaround until plain jq is up to speed.**"
	echo
	echo "  ${COLOR_WHITE}generate${COLOR_NO_COLOR} <github username> <package name> \"<one sentence to describe the package>\""
	echo "    Generate a jq/jqnpm package skeleton in a subfolder."
	echo "    Package name: all lowercase, separate words with a dash '-'. Don't use a 'jq-' prefix."
	echo "    Package name example: cool-tool"
}
