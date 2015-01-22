function initialize {
	(( "$#" != 0 )) && die 100 "not the right number of arguments to '$FUNCNAME'"
	createMinimalJqJsonIfNecessary
	createPackageRootIfNecessary
	createMinimalMainJqIfNecessary
}
