function help {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	consoleOutputWithColors "${COLOR_WHITE}jqnpm${COLOR_NO_COLOR}: npm style package manager for jq"
	consoleOutputWithColors "${COLOR_WHITE}https://github.com/joelpurra/jqnpm${COLOR_NO_COLOR}"
	consoleOutputEmptyLine
	consoleOutputWithColors "jqnpm ${COLOR_WHITE}<action>${COLOR_NO_COLOR} [options]"
	consoleOutputEmptyLine
	consoleOutputWithColors "Actions:"
	consoleOutputWithColors "  ${COLOR_WHITE}help${COLOR_NO_COLOR}"
	consoleOutputWithColors "    Show this help."
	consoleOutputEmptyLine
	consoleOutputWithColors "  ${COLOR_WHITE}initialize${COLOR_NO_COLOR}"
	consoleOutputWithColors "    Create default ${packageMetadataFilename} and ${defaultPackageJqFile} files and the ${packageMetadataDirectoryName}/ package root."
	consoleOutputWithColors "      Alias: ${COLOR_WHITE}init${COLOR_NO_COLOR}"
	consoleOutputEmptyLine
	consoleOutputWithColors "  ${COLOR_WHITE}fetch${COLOR_NO_COLOR} [package]"
	consoleOutputWithColors "    Preload package cache from remote server."
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}package${COLOR_NO_COLOR}: (optional) a package name such as 'joelpurra/jq-stress'"
	consoleOutputEmptyLine
	consoleOutputWithColors "  ${COLOR_WHITE}install${COLOR_NO_COLOR} [[--global|-g] package]"
	consoleOutputWithColors "    Install/add ${packageMetadataFilename} dependencies to the current directory."
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}--global${COLOR_NO_COLOR}: (optional) (alias: -g) use to install to '$(echo -nE "$globalJqPackageBase" | replaceHomeWithTilde)' instead of '${localJqPackageBase}'"
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}package${COLOR_NO_COLOR}: (optional) a package name such as 'joelpurra/jq-stress'"
	consoleOutputEmptyLine
	consoleOutputWithColors "  ${COLOR_WHITE}execute${COLOR_NO_COLOR} [flags for jq]"
	consoleOutputWithColors "    Run normal jq with dependencies. **This is a workaround until plain jq is up to speed.**"
	consoleOutputWithColors "      Alias: ${COLOR_WHITE}exec${COLOR_NO_COLOR}"
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}flags for jq${COLOR_NO_COLOR}: (optional) ordinary jq flags, such as --null-input (-n)."
	consoleOutputEmptyLine
	consoleOutputWithColors "  ${COLOR_WHITE}generate${COLOR_NO_COLOR} <github username> <package name> \"<one sentence to describe the package>\""
	consoleOutputWithColors "    Generate a jq/jqnpm package skeleton in a subfolder."
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}github username${COLOR_NO_COLOR}: (required) used for publishing to github."
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}package name${COLOR_NO_COLOR}: (required) all lowercase, separate words with a dash '-'. Example: cool-tool"
	consoleOutputWithColors "      ${COLOR_LIGHT_GRAY_UNDERLINE}one sentence to describe the package${COLOR_NO_COLOR}: (required) a snappy package description."
}
