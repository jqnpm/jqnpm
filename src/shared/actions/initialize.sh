function initialize {
	(( "$#" != 0 )) && die 1 "not the right number of arguments to '$FUNCNAME'"
	createEmptyJqJsonIfNecessary
	createEmptyMainJqIfNecessary
}
