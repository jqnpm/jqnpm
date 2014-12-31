#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/shunit2-colorize.sh"

source shunit2 |& colorizeShUnit2
