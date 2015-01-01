# [jqnpm](https://github.com/joelpurra/jqnpm) - [jq](https://stedolan.github.io/jq/) package manager

A package manager built for the command-line JSON processor [`jq`](https://stedolan.github.io/jq/) as an example implementation. This is experimental software. [Want to contribute?](https://github.com/joelpurra/jqnpm/blob/master/CONTRIBUTE.md)


## Features

- Uses only namespaced packages, for example `joelpurra/jq-another-utility`.
- Uses github.com by default; the example would be cloned from `github.com/joelpurra/jq-another-utility`.
- Uses strict [semantic versioning](http://semver.org/) tags.
- Run `jqnpm init` to create `src/main.jq` and `jq.json` with your package metadata, including:
  - Package name (*defaults to the folder name*).
  - Version.
  - Dependencies and their versions.
  - Compatible `jq` versions.
  - ([optional](https://github.com/joelpurra/jqnpm/blob/master/BUILDING.md)) Softer metadata like author name and package license.
- Code meant to only *consume* other packages are also called projects. They have a `jq.json` file as well.

### Additional features

- Dependencies are stored in `./.jq/packages/` per package.
- A local cache in `~/.jq/` stores remote repositories.
- No *centrally managed* server side package repository is needed to publish your packages - just create a repository on github!
- Can also use bitbucket and other online services, where usernames or organization names act as namespaces.



## Get it

- Clone the repository and add `src/` to your `$PATH`.
- Requirement: [jq](https://stedolan.github.io/jq/) 1.5rc1+ in your `$PATH`. See the [`stedolan/jq` master branch](https://github.com/stedolan/jq/). Tested with [jq-1.5rc1-1-g157c95b](https://github.com/stedolan/jq/commit/157c95b9889b523a3de7772e85ef9f3f69182c88), which is •not yet fully compatible* with `jqnpm`.
- Requirement: [bash](https://www.gnu.org/software/bash/) 4+ in your `$PATH`
- Requirement: [git](http://git-scm.com/)

```
git clone --recursive git://github.com/joelpurra/jqnpm.git
```



## Usage

Also see each source file, but don't expect much documentation yet.

#### Commands


```text
jqnpm <action> [options]

Actions
  help                      Show this help.
  initialize                Create default jq.json and src/main.jq files.
  fetch [package]           Preload package cache from remote server.
  install [package]         Install/add jq.json dependencies to the current directory.
  execute [flags for jq]    Run normal jq with dependencies. **This is a workaround until plain jq is up to speed.**
```


#### Example command line usage

```shell
cd my-project/                                    # Your project.
jqnpm init                                           # (optional) Create jq.json and src/main.jq.
jqnpm install joelpurra/jq-another-utility           # Also creates a minimal jq.json.

# 'jqnpm execute' is a wrapper around jq, which also loads dependencies managed by jqnpm.
# **'jqnpm execute' is a workaround until plain jq is up to speed.**
# Use the way you would use jq, including flags:
# Example A:
echo '{ "hello": "world" }' | jqnpm execute '.hello'

# Example B:
jqnpm execute -n '"No input necessary"'

# Example C:
<"input.json" jqnpm execute --slurp >"output.json"
```

### `jq.json`

Contains all metadata for the package/project. Keeps code files clean! See also the [normal `jq.json` example](https://github.com/joelpurra/jqnpm/edit/master/BUILDING.md).


Shows example dependency `joelpurra/jq-another-utility` with version range `^1.0.0` [resolving to](https://github.com/npm/node-semver#caret-ranges-123-025-004) `>=1.0.0 <2.0.0`.

```json
{
    "name": "jq-one-single-utility",
    "version": "0.1.0",
    "main": "./src/jq-one-single-utility.jq",
    "dependencies": {
        "joelpurra/jq-another-utility": "^1.0.0"
    },
    "engines": {
        "jq": "^1.5.0",
        "jqnpm": "^1.0.0"
    }
}
```

### `src/main.jq`

Example usage combining two other packages.

```jq
import "joelpurra/jq-another-utility" as anotherUtility;
import "anotheruser/jq-url-splitting" as urlSplitting;

def prepareAndSplit:
    anotherUtility::doSomething | urlSplitting::split;

{
    "my-url-parts": prepareAndSplit
}
```


---

## License
Copyright (c) 2014, Joel Purra <http://joelpurra.com/>
All rights reserved.

When using jqnpm, comply to at least one of the three available licenses: BSD, MIT, GPL.
Please see the LICENSE file for details.


