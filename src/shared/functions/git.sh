function getHEADCommitHash {
	git rev-parse --short --verify HEAD
}
