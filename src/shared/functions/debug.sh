function isDebugAtLevel {
	(( "$#" < 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	local -i messageLevel="$1"
	shift

	if (( ${JQNPM_DEBUG_LEVEL:-2} >= $messageLevel ));
	then
		return 0;
	fi

	return 1;
}

function getMessageLevelName {
	case "$1" in
		0)
			echo -nE 'FATL'
			;;
		1)
			echo -nE 'ERRO'
			;;
		2)
			echo -nE 'WARN'
			;;
		3)
			echo -nE 'INFO'
			;;
		4)
			echo -nE 'DEBG'
			;;
		5)
			echo -nE 'VRBO'
			;;
		6)
			echo -nE 'TRCE'
			;;
		*)
			echo -nE 'OMG!'
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

		echo -nE "jqnpm: [${messageLevelName}]" >&2
		echo -ne "\t" >&2
		echo -E "$@" >&2
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
