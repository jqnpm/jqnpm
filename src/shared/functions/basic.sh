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
