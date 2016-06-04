# Join an array as delimited string.
# http://stackoverflow.com/a/17841619
function join { local IFS="$1"; shift; echo -E "$*"; }

function containsUppercaseAscii {
	if [[ "$1" =~ [A-Z] ]];
	then
		return 0;
	fi

	return 1;
}

function replaceHomeWithTilde {
	local fixedHome="${HOME//|/\|}"

	sed "s|$fixedHome|~|g"
}

function arrayContainsValue {
	local value="$1"
	shift

	for v in "$@";
	do
		if [[ "$value" == "$v" ]];
		then
			return 0;
		fi
	done

	return 1;
}

function joinLines {
	tr -d '\n-'
}

function dashesToPascalCase {
	sed -e '1 s/^/-/' -e 's/-./\
&\
/g' | sed -e '/^-.$/ y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' -e 's/-//g' | joinLines
}

function consoleOutput {
	echo -E "$@"
}

function consoleOutputSameLine {
	echo -nE "$@"
}

function consoleOutputWithColors {
	echo -e "$@"
}

function consoleOutputSameLineWithColors {
	echo -ne "$@"
}

function consoleOutputEmptyLine {
	echo -E
}

declare COLOR_BLUE="\033[0;34m"
declare COLOR_RED="\033[0;31m"
declare COLOR_LIGHT_RED="\033[1;31m"
declare COLOR_LIGHT_GRAY="\033[0;37m"
declare COLOR_LIGHT_GREEN="\033[1;32m"
declare COLOR_LIGHT_BLUE="\033[1;34m"
declare COLOR_LIGHT_CYAN="\033[1;36m"
declare COLOR_YELLOW="\033[1;33m"
declare COLOR_WHITE="\033[1;37m"

declare COLOR_LIGHT_GRAY_UNDERLINE="\033[4;37m"

declare COLOR_NO_COLOR="\033[0m"
