function runAllFourLineTests () {
	DONE=false
	until $DONE;
	do
		declare COLOR_WHITE="[1;37m"
		declare COLOR_NO_COLOR="[0m"

		local title
		local description
		local input
		local code
		local expected

		IFS=':' read -d ':' title
		read description
		read input
		read code
		read expected

		echo -ne "$COLOR_WHITE"
		echo -nE "$title"
		echo -ne "$COLOR_NO_COLOR"
		echo -E ": $description"

		local expectedFormatted=$(echo "$expected" | jq '.')

		local output=$(echo "$input" | jq -f <(echo "$code" | cat "$fileUnderTest" -))

		assertEquals "${title}: ${description}" "$expectedFormatted" "$output"

		read || DONE=true # Empty line between tests.
	done
}


# Requires shUnit2.
# https://code.google.com/p/shunit2/
[[ -z $(which shunit2) ]] && { echo "shunit2 is required." >&2; exit 1; }
source shunit2
