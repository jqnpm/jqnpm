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
