# Write your jq script here!
#
# You can import any depedencies defined in 'jq.json' like this:
#import "joelpurra/jq-object-sorting" as ObjectSorting;

def myFirstFunction:
	. as $name
	| "Hello \($name)!";
