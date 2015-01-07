function getBestNewDotJqDirectoryPath {
	if isInsidePackageWithRoot;
	then
		die 300 "can't create a new '$packageMetadataDirectoryName' inside an existing package."
	fi

	if hasPackageMetadataFile;
	then
		local nearestJqJsonDirectory=$(getNearestJqJsonDirectory)

		echo -nE "${nearestJqJsonDirectory}/${packageMetadataDirectoryName}"

		return 0;
	fi

	echo -nE "$packageMetadataDirectoryName"

	return 0;
}

function createPackageRootIfNecessary {
	if ! isInsidePackageWithRoot;
	then
		local bestNewDotJqDirectoryPath=$(getBestNewDotJqDirectoryPath)

		debug 5 "creating package root in: '${bestNewDotJqDirectoryPath}' in '$PWD'"

		mkdir -p "$bestNewDotJqDirectoryPath"
	fi
}

function getLocalPackageRoot {
	# Here 'local' means not in $HOME.

	local originalPWD="$PWD"

	(
		until [[ -d "$packageMetadataDirectoryName" ]];
		do
			cd ..

			if [[ "$PWD" == "/" || "$PWD" == "$HOME" ]];
			then
				debug 5 "could not find nearest 'local' package root starting in '$(echo -nE "$originalPWD" | replaceHomeWithTilde)'"

				return 1;
			fi
		done

		debug 5 "found nearest 'local' package root '$(echo -nE "$PWD" | replaceHomeWithTilde)' starting in '$(echo -nE "$originalPWD" | replaceHomeWithTilde)'"

		echo -nE "${PWD}"
	)

	return 0;
}

function isInsidePackageWithRoot {
	if [[ ! -z $(getLocalPackageRoot 2>/dev/null) ]];
	then
		return 0;
	fi

	return 1;
}

function getBestEffectivePackageRoot {
	if isInsidePackageWithRoot;
	then
		getLocalPackageRoot

		return 0;
	fi

	if hasPackageMetadataFile;
	then
		getNearestJqJsonDirectory

		return 0;
	fi

	echo -nE "$PWD"

	return 0;
}

