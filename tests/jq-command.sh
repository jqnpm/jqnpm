#!/usr/bin/env bash

# Want to override the `jq` command?
# Put the command in `jq-command-override.sh`.
#
# EXAMPLE 1
# echo 'jqnpm execute "$@"' >"jq-command-override.sh"
# chmod u+x "jq-command-override.sh"
#
# EXAMPLE 2
# echo 'jq "$@"' >"jq-command-override.sh"
# chmod u+x "jq-command-override.sh"
#
# EXAMPLE 3
# echo '/my/custom/jq "$@"' >"jq-command-override.sh"
# chmod u+x "jq-command-override.sh"

# This is the current default command to interpret jq scripts.
jqnpm execute "$@"
