# [jqnpm](https://github.com/joelpurra/jqnpm) - [jq](https://stedolan.github.io/jq/) package manager

A package manager built for `jq` as an example implementation. This is experimental software.


## Features

- Each package can depend on other packages.
- Package metadata is written in `jq.json`. Metadata includes package name, version, compatible jq versions, dependencies and their versions - and softer things like author name and package license.
- Packages are meant to be stored in a `./.jq/packages/` per-package subdirectory.
- Code meant to only *consume* other packages are also called projects. They have a `jq.json` file as well, to define dependencies, project name, licences etcetera.
- Aims to use only namespaced packages, for example `joelpurra/jq-another-utility`, which means no *centrally managed* server side package repository is needed.
- Can use git, hg and other D/VCS', provided that something like tags exist.
- Can use github, bitbucket and other online services, where usernames or organization names act as namespaces. This allows forks to be used without collisions in a centralized system.



## Get it

- Clone the repository and add `src/` to your `$PATH`.
- [jq](https://stedolan.github.io/jq/) 1.4+ on your `$PATH`. A version with a `module` system implementation is required; [`stedolan/jq` master branch might have it](https://github.com/stedolan/jq/). Tested with [56ae88d](https://github.com/stedolan/jq/commit/56ae88d9d55582e8d0036601e3186d88861bf105).
- [bash](https://www.gnu.org/software/bash/) 4+

```
git clone --recursive git://github.com/joelpurra/jqnpm.git
```



## Usage

Also see each source file, but don't expect much documentation yet.


### Command line

```shell
cd local-project/		# Your project.
nano jq.json			# Add dependencies.
jqnpm help              # Display command help.
jqnpm install           # Look in ./.jq/packages/ afterwards to confirm.

# 'jqnpm execute' is a wrapper around jq, which also loads dependencies managed by jqnpm.
# Use the way you would use jq, including flags.
jqnpm execute -n
<input.json jqnpm execute --slurp >output.json

```

### `jq.json`

Contains all metadata necessary for the repository. Keeps code files clean!


#### Minimal

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


#### Normal

```json
{
    "name": "jq-one-single-utility",
    "version": "0.1.0",
    "description": "My awesome jq utility",
    "homepage": "https://github.com/joelpurra/jq-one-single-utility",
    "bugs": "https://github.com/joelpurra/jq-one-single-utility/issues",
    "author": {
        "name": "Joel Purra",
        "url": "http://joelpurra.com/"
    },
    "main": "./src/jq-one-single-utility.jq",
    "repository": {
        "type": "git",
        "url": "git://github.com/joelpurra/jq-one-single-utility.git"
    },
    "dependencies": {
        "joelpurra/jq-another-utility": "^1.0.0",
        "anotheruser/jq-url-splitting": "^2.3.4",
        "someuser/jq-smart-object-merging": "^0.7.1",
    },
    "engines": {
        "jq": "^1.5.0",
        "jqnpm": "^1.0.0"
    },
    "licenses": [{
        "type": "MIT",
        "url": "http://joelpurra.mit-license.org/2014"
    }],
    "keywords": [
        "jq-package"
    ]
}
```

### `src/main.jq`

Example usage combining two other packages.

```jq
import joelpurra/jq-another-utility::src::main as anotherUtility;
import anotheruser/jq-url-splitting::src::main as urlSplitting;

def prepareAndSplit:
    anotherUtility::doSomething | urlSplitting::split;

{
    "my-url-parts": prepareAndSplit
}
```


## Background


### jq's modules

> [jq](https://stedolan.github.io/jq/) is a lightweight and flexible command-line JSON processor.

- Built to satisfy the need for a package manager to handle jq's (future, v1.4+) module system.
- [stedolan/jq#491 Enhancement request: integrated package manager](https://github.com/stedolan/jq/issues/491)
- [stedolan/jq#566 Semantic version utility](https://github.com/stedolan/jq/issues/566)
- [stedolan/jq#535 List of publicly released modules?](https://github.com/stedolan/jq/issues/535)


### Style

- Based on [Node Package Manager](https://npmjs.org/)'s style.
- All package versions follow the [Semantic Versioning](http://semver.org/) scheme strictly.
- Version parsing and matching aims to follow [node-semver](https://github.com/npm/node-semver).
- Written in bash shell scripts, but it might not be the optimal choice in the long run.


### Requirements for the `jq` binary

- Implement a simple package directory finding logic in `jq`, like how [modules](http://nodejs.org/api/modules.html) installed by `npm` are [resolved](http://nodejs.org/api/modules.html#modules_all_together) by `node`.
- No `module` statement is necessary. It only clutters jq script files, as metadata is best kept in `./jq.json` per package.
- A simple `import` statement accepting a string and an alias: `import "<package>" as <alias>;`.
  - No other configuration, such as versions, goes in the `import` statement.
  - The `<package>` is defined as (or at least parsed as) a string.
- The package root is defined as the current/first parent directory with a `.jq/` subdirectory. Only one is allowed per package.
- Implement a simple per-package `./jq.json` lookup for the `"main": "./src/completely-separate-from-module-name.jq"` property, or fall back to `./src/main.jq`.


#### Example [`import` resolving algorithm](http://nodejs.org/api/modules.html#modules_all_together)
- Strings exactly matching packages/modules internal to the current `jq` build are loaded with priority.
- Strings starting with `./`, `../` or `/` are treated as paths.
  - Paths can point to:
    - A specific file:
      - `./more/code-goes-here.jq` (for example).
      - `../data/data-goes-here.json` (for example).
    - A directory containing:
      - A `jq.json` file.
        - With a `main` property path.
      - A subpath `src/main.jq`.
      - A subpath `src/main.json`.
- Other strings are treated as package names.
  - Packages in the package root's `./.jq/packages/` subdirectory.
  - (From [other documentation](https://github.com/stedolan/jq/blob/56ae88d9d55582e8d0036601e3186d88861bf105/docs/content/3.manual/manual.yml)) The default search path is the search path given to the `-L` command-line option, else the "$JQ_LIBRARY_PATH", if set in the environment, else `["~/.jq", "$ORIGIN/../lib/jq"]` (on Unix) or `["~/.jq", "$ORIGIN/lib"]` (on Windows).
- If nothing could be resolved, throw error.


### Issues

- The package names are currently duplicated between `./jq.json` and `./src/main.jq`. This is due to two things.
  - `jq` is unaware of each dependency's subdirectory.
  - `jqnpm` uses only `./src/main.jq` at the moment. The `main` responsibility might end up in `jq` instead.
- Packages are not recursively resolved during execution. This is due to relative module paths starting with `./` only being resolved against the *initial* `src/main.jq`, not subsequently called dependencies.


### Alternative solutions

- Store all packages user-globally in `~/.jq/packages/` with `~/.jq/packages/<package>/<semantic version>/` subdirectories.
  - Positive:
    - Makes it easier to re-use packages across projects.
    - Globally installed packages are less different from locally/per-project dependencies.
  - Negative:
    - Dependencies would no longer be fully private to each package in a private `./jq/packages` directory.
    - Harder to export a fully functioning jq-dependent project as-is to another machine without accessing/affecting user-global directories.
    - Requires version names in the directory structure, which would require changes to the jq core.
    - Requires the `jq` binary to look up version numbers to match between `./jq.json` dependency ranges and `~/.jq/packages/<package>/<semantic version>/` lists.
      - Can be solved with symbolic links from a local `./.jq/packages/<package>/` to a user-global `~/.jq/packages/<package>/<semantic version>/`.
      - Symbolic links may be too error-prone for cross-platform code.
- Store all packages in a flat hierarchy per project,  in `./.jq/packages/` with `./.jq/packages/<package>/<semantic version>/` subdirectories.
  - Positive:
    - Would still allow easy export of the project directory as-is to another machine.
  - Negative:
    - Dependencies would no longer be fully private to each package in a private `./jq/packages` directory.
    - Requires version names in the directory structure, which would require changes to the jq core.
- Using a subdirectory for the main jq file, `./src/main.jq`, can be discussed. At least it separates code files from the ordinary readme/license/metadata file clutter.


### Ideas

- Implement user-global storage of executable jq scripts in `~/.jq/bin/`, which can be added to `$PATH`.
- Enforce `jq.json`'s `engine` property version range for `jq` and `jqnpm`.



## Original purpose

The library was built awaiting and expecting a complete jq package system, and to show how I expect the `module` statement to be used.



## TODO

*Patches/pull requests welcome!*

* Write tests.
* Split up files into smaller parts.



## License
Copyright (c) 2014, Joel Purra <http://joelpurra.com/>
All rights reserved.

When using jqnpm, comply to at least one of the three available licenses: BSD, MIT, GPL.
Please see the LICENSE file for details.


