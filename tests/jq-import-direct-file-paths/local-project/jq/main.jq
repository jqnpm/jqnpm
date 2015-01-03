import "./same-folder.jq" as sameFolder;
import "./more/subfolder.jq" as subFolder;
import "../other/sibling-folder.jq" as siblingFolder;
import "../parent-folder.jq" as parentFolder;
import "../../outside-of-package.jq" as outsidePackageFolder;

# TODO: absolute paths. Is there a (valid) jq file that exists across systems?

[
	"main.jq",
	sameFolder::f,
	subFolder::f,
	siblingFolder::f,
	parentFolder::f,
	outsidePackageFolder::f
]
| join("|")
