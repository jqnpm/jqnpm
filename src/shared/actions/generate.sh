declare -A cachedGithubUserInformation

function fetchGithubUserInformation {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: validate username format.
	local username="$1"
	local githubUserInformationUrl="${JQNPM_GITHUB_API_BASE:-$config_default_GithubApiBase}/users/${username}"

	debug 5 "Fetching github user information: '$(echo -nE "$githubUserInformationUrl" | replaceHomeWithTilde)'"

	curl --silent "$githubUserInformationUrl"
}

function getGithubUserInformation {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: validate username format.
	local username="$1"
	local tempFilePath=$(getAdressableTempFilePath "github-${username}.json")

	debug 5 "Github user information cache: '$tempFilePath'"

	if [[ ! -s "$tempFilePath" ]];
	then
		debug 4 "Github user information cache was empty, fetching"

		fetchGithubUserInformation "$username" > "$tempFilePath"
	fi

	cat "$tempFilePath"
}

function getGithubFullname {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: validate username format.
	local username="$1"

	getGithubUserInformation "$username" | jq --join-output '.name // ""'
}

function getGithubUserHomepageUrl {
	(( "$#" != 1 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: validate username format.
	local username="$1"

	getGithubUserInformation "$username" | jq --join-output '.blog // ""'
}

function generate {
	(( "$#" != 3 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	# TODO: validate username format.
	local username="$1"
	shift
	# TODO: validate package name.
	local packageName="$1"
	shift
	local oneSentenceDescription="$1"
	shift

	if packageNameStartsWithLowercaseJqDash "$packageName";
	then
		packageName="${packageName:3}"
	fi

	local fullPackageName="jq-${packageName}"
	local packageJqAlias=$(echo -nE "$packageName" | dashesToPascalCase)

	local userFullName=$(getGithubFullname "$username")
	if [[ -z "$userFullName" ]];
	then
		userFullName="$username"
	fi

	local userHomepageUrl=$(getGithubUserHomepageUrl "$username")
	if [[ -z "$userHomepageUrl" ]];
	then
		userHomepageUrl="${JQNPM_GITHUB_BASE:-$config_default_GithubBase}/${username}"
	fi

	debug 3 "Full name and homepage for github user '${username}': '${userFullName}', '${userHomepageUrl}'"

	local defaultPackageVersion='0.1.0'
	local currentYear=$(date +%Y)

	local pluginOutputBase="$PWD"
	local pluginOutputPath="${pluginOutputBase}/${fullPackageName}"
	local pluginInputPath="${JQNPM_SOURCE%/*}/../resources/template/package"


	debug 3 "Creating output directory: '$(echo -nE "$pluginOutputPath" | replaceHomeWithTilde)'"

	[[ -d "$pluginOutputPath" || -e "$pluginOutputPath" ]] && die 400 "could not generate package; the folder exists: '$(echo -nE "$pluginOutputPath" | replaceHomeWithTilde)'"

	mkdir -p "$pluginOutputPath"


	# Initialize a new git repository.
	local remoteWriteableRepository="${JQNPM_GITHUB_REPOSITORY_WRITEABLE_BASE:-$config_default_GithubRepositoryWriteableBase}${username}/${fullPackageName}${JQNPM_GITHUB_REPOSITORY_WRITEABLE_SUFFIX:-$config_default_GithubRepositoryWriteableSuffix}"

	pushd "$pluginOutputPath" >/dev/null
	git init | replaceHomeWithTilde
	set +e
	git remote add -f -t 'master' -m 'master' 'origin' "$remoteWriteableRepository" &>/dev/null
	git checkout master &>/dev/null
	git pull --rebase &>/dev/null
	set -e
	popd >/dev/null


	# Copy the  files to the target directory.
	cp -iR "${pluginInputPath}/." "$pluginOutputPath"


	# Find files in the target directory.
	declare -a filesInOutput=()
	while IFS= read -r -d '' fileInOutput;
	do
		filesInOutput+=("$fileInOutput")
	done < <(find "$pluginOutputPath" -type f -not -path '*/.git/*' -print0)

	debug 5 "Found ${#filesInOutput[@]} files in: '$(echo -nE "$pluginOutputPath" | replaceHomeWithTilde)'"


	# Run template replacements.
	for fileInOutput in "${filesInOutput[@]}";
	do
		debug 4 "Replacing values: '$(echo -nE "$fileInOutput" | replaceHomeWithTilde)'"

		local tempFilePath=$(getTempFilePath)

		cat "$fileInOutput" | sed \
		-e "s|<%=GITHUB_USERNAME%>|$username|g" \
		-e "s|<%=PACKAGE_NAME%>|$packageName|g" \
		-e "s|<%=FULL_PACKAGE_NAME%>|$fullPackageName|g" \
		-e "s|<%=DEFAULT_PACKAGE_VERSION%>|$defaultPackageVersion|g" \
		-e "s|<%=ONE_SENTENCE_DESCRIPTION%>|$oneSentenceDescription|g" \
		-e "s|<%=PACKAGE_ALIAS%>|$packageJqAlias|g" \
		-e "s|<%=FULL_NAME%>|$userFullName|g" \
		-e "s|<%=USER_HOMEPAGE_URL%>|$userHomepageUrl|g" \
		-e "s|<%=CURRENT_YEAR%>|$currentYear|g" \
		>"$tempFilePath"

		mv "$tempFilePath" "$fileInOutput"
	done


	# Set permissions for, and execute the tests.
	local testPath="${pluginOutputPath}/tests/all.sh"

	consoleOutputWithColors "Executing tests: '${COLOR_WHITE}$(echo -nE "$testPath" | replaceHomeWithTilde)${COLOR_NO_COLOR}'"

	chmod 'u+x' "$testPath"
	( "$testPath" )

	# Encourage following guidelines.
	consoleOutputEmptyLine
	consoleOutputWithColors "Package '${COLOR_WHITE}${packageName}${COLOR_NO_COLOR}' has been generated in '${COLOR_WHITE}$(echo -nE "$pluginOutputPath" | replaceHomeWithTilde)${COLOR_NO_COLOR}'."
	consoleOutputEmptyLine
	consoleOutputWithColors "Next steps:"
	consoleOutputWithColors "  ${COLOR_WHITE}1. ${COLOR_NO_COLOR} Create a new respository called ${COLOR_WHITE}${fullPackageName}${COLOR_NO_COLOR} on ${COLOR_WHITE}https://github.com/new${COLOR_NO_COLOR}"
	consoleOutputWithColors "  ${COLOR_WHITE}2. ${COLOR_NO_COLOR} Write code in ${COLOR_WHITE}jq/main.jq${COLOR_NO_COLOR}"
	consoleOutputWithColors "  ${COLOR_WHITE}3. ${COLOR_NO_COLOR} Write tests in ${COLOR_WHITE}tests/all.sh${COLOR_NO_COLOR}"
	consoleOutputWithColors "  ${COLOR_WHITE}4. ${COLOR_NO_COLOR} Write usage instructions in ${COLOR_WHITE}README.md${COLOR_NO_COLOR}"
	consoleOutputWithColors "  ${COLOR_WHITE}5. ${COLOR_NO_COLOR} Commit your changes and push them."
	consoleOutputWithColors "  ${COLOR_WHITE}6. ${COLOR_NO_COLOR} Create a new version tag and push it: ${COLOR_WHITE}git tag -a v${defaultPackageVersion} -m v${defaultPackageVersion} && git push origin v${defaultPackageVersion}${COLOR_NO_COLOR}"
	consoleOutputEmptyLine
	consoleOutputWithColors "Please read package guidelines on the jqnpm homepage."
	consoleOutputWithColors "${COLOR_WHITE}https://github.com/joelpurra/jqnpm${COLOR_NO_COLOR}"
}
