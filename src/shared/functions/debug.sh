function isDebugAtLevel {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	if (( ${JQNPM_DEBUG_LEVEL:-2} >= $messageLevel ));
	then
		return 0;
	fi

	return 1;
}

function getMessageLevelName {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	case "$1" in
		0)
			consoleOutputSameLineWithColors "${COLOR_RED}FATL${COLOR_NO_COLOR}"
			;;
		1)
			consoleOutputSameLineWithColors "${COLOR_RED}ERRO${COLOR_NO_COLOR}"
			;;
		2)
			consoleOutputSameLineWithColors "${COLOR_YELLOW}WARN${COLOR_NO_COLOR}"
			;;
		3)
			consoleOutputSameLineWithColors "${COLOR_LIGHT_BLUE}INFO${COLOR_NO_COLOR}"
			;;
		4)
			consoleOutputSameLineWithColors "${COLOR_WHITE}DEBG${COLOR_NO_COLOR}"
			;;
		5)
			consoleOutputSameLineWithColors "VRBO"
			;;
		6)
			consoleOutputSameLineWithColors "${COLOR_LIGHT_GRAY}TRCE${COLOR_NO_COLOR}"
			;;
		*)
			consoleOutputSameLineWithColors "${COLOR_LIGHT_RED}OMG!${COLOR_NO_COLOR}"
			;;
	esac
}

function debug {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	if isDebugAtLevel "$messageLevel";
	then
		local messageLevelName=$(getMessageLevelName "$messageLevel")

		consoleOutputSameLine "jqnpm: [${messageLevelName}]" >&2
		consoleOutputSameLineWithColors "\t" >&2
		consoleOutput "$@" >&2
	fi

	return 0;
}

function debugInPackageIfAvailable {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	if hasPackageMetadataFile &>/dev/null;
	then
		debugInPackage "$messageLevel" "$@"
	else
		debug "$messageLevel" "$@"
	fi

	return 0;
}

function debugInPackage {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	debug "$messageLevel" "[$(getValidPackageNameOrEmptyString)]" "$@"

	return 0;
}

function die {
	(( "$#" < 2 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i exitcode="$1"
	shift

	debug 0 "$@"
	exit "$exitcode"
}
