#!/usr/bin/env bash


fileUnderTest="${BASH_SOURCE%/*}/../jq/main.jq"


read -d '' fourLineTests <<-'EOF' || true
myFirstFunction: Can say hello.
"World"
myFirstFunction
"Hello World!"

General test case title: This is a test description.
{ "some": "input" }
.some |= sub("in"; "out")
{ "some": "output" }
EOF

function testAllFourLineTests () {
	echo "$fourLineTests" | runAllFourLineTests
}


# Run tests above automatically.
# Custom tests can be added by adding new function with a name that starts with "test": function testSomething () { some test code; }
source "${BASH_SOURCE%/*}/test-runner.sh"
