# Contribute to [jqnpm](https://github.com/joelpurra/jqnpm)

This is experimental software, so feedback is most appreciated!

- You can [open an issue for your problem or suggestion](https://github.com/joelpurra/jqnpm/issues).
- Learn how to [create your own package](https://github.com/joelpurra/jqnpm#creating-a-package).
- Learn how to [contribute code to `jqnpm`](https://github.com/joelpurra/jqnpm/blob/master/BUILDING.md).



## Known issues

- The package names are currently duplicated between `./jq.json` and `./jq/main.jq`. This is due to two things:
  1. `jq` is unaware of each dependency's subdirectory.
  1. `jqnpm` uses only `./jq/main.jq` at the moment. The `main` responsibility might end up in `jq` instead.
- Packages are not recursively resolved during execution. This is due to relative module paths starting with `./` only being resolved against the *initial* `jq/main.jq`, not subsequently called dependencies.



## Additional features

- Dependencies are stored in `./.jq/packages/` per package.
- A local cache in `~/.jq/` stores remote repositories.
- No *centrally managed* server side package repository is needed to publish your packages -- just create a repository on github!
- As packages are stored on [github.com](https://github.com/) (by default), an account there is required for `jqnpm`. Because github allows private repositories, you can use `jqnpm` for private packages; this has not been tested yet.
- Can also use bitbucket and other online services, where usernames or organization names act as namespaces.



## TODO

*Patches/pull requests welcome!*

- Write additional tests, and add relevant asserts to current tests.
- Split up files into smaller parts.



## Ideas

- Implement user-global storage of executable jq scripts in `~/.jq/bin/`, which can be added to `$PATH`.
- Enforce `jq.json`'s `engine` property version range for `jq` and `jqnpm`.



## Background

In order to understand the direction of the development, you could spend an hour or two reading all of this. If you are already familiar with [`npm`](https://npmjs.org/), you might actually be able to skip all of the reading.


### jq's modules

> [jq](https://stedolan.github.io/jq/) is a lightweight and flexible command-line JSON processor.

- Built to satisfy the need for a package manager to handle jq's (future, v1.4+) module system.
- [stedolan/jq#491 Enhancement request: integrated package manager](https://github.com/stedolan/jq/issues/491)
- [stedolan/jq#566 Semantic version utility](https://github.com/stedolan/jq/issues/566)
- [stedolan/jq#535 List of publicly released modules?](https://github.com/stedolan/jq/issues/535)


### Style

- Based on [Node Package Manager](https://npmjs.org/)'s style.
- All package versions follow the [Semantic Versioning](https://semver.org/) scheme strictly.
- Version parsing and matching aims to follow [node-semver](https://github.com/npm/node-semver).
- Written in bash shell scripts, but it might not be the optimal choice in the long run.


### Requirements for the `jq` binary

- Implement a simple package directory finding logic in `jq`, like how [modules](https://nodejs.org/api/modules.html) installed by `npm` are [resolved](https://nodejs.org/api/modules.html#modules_all_together) by `node`.
- No `module` statement is necessary. It only clutters jq script files, as metadata is best kept in `./jq.json` per package.
- A simple `import` statement accepting a string and an alias: `import "<package>" as <alias>;`.
  - No other configuration, such as versions, goes in the `import` statement.
  - The `<package>` is defined as (or at least parsed as) a string.
- The package root is defined as the current/first parent directory with a `.jq/` subdirectory. Only one is allowed per package.
- Implement a simple per-package `./jq.json` lookup for the `"main": "./some-path/completely-separate-from-module-name.jq"` property, or fall back to `./jq/main.jq`.


#### Example [`import` resolving algorithm](https://nodejs.org/api/modules.html#modules_all_together)

- Here `P` means the package root: the first of the current or any parent directory which contains a directory `.jq/`.
- Here `D` means a directory referenced during the lookups.
- Here `F` means the file used by `jq` for further parsing of the contents.

For `import "<package>" as <alias>;` follow these steps to find `D`:

- `<package>` strings exactly matching packages/modules internal to the current `jq` build are loaded with priority.
- `<package>` strings starting with `./`, `../` or `/` are treated as paths.
  - Absolute paths starting with `/`:
    - Start in the (file) system root `/` on non-Windows systems.
    - Are used as [`file://` paths on Windows systems](https://en.wikipedia.org/wiki/File_URI_scheme): `file://` + `/c:/dev/directory/` -> `file:///c:/dev/directory/`.
  - Relative paths starting with `./` or `../` are relative to:
    - The directory containging the jq script file which used the `import` statement.
    - The current directory `$PWD` if the script is given on the command line: `jq 'import ...'`.
  - `<package>` strings which are paths can point to:
    1. A file path which becomes `F`.
    1. A directory path which becomes `D` and used the directory lookup steps below.
- Other strings are treated as package names:
  - Package names can use `/` as directory delimiters.
  - Package names are relative to `P/.jq/packages/`.
  - Let `D` be `P/.jq/packages/<package>/` and used the directory lookup steps.
- If `D` is set, follow these directory lookup steps:
  1. A path `D/jq/main.jq`, which if it exists becomes `F`.
  1. A path `D/data/main.json`, which if it exists becomes `F`.
  1. If `D/jq.json` is a file which exists:
    - Use the `main` property path `cat D/jq.json | jq '.main'` as `F`.
- Treating `F`:
  - If the file `F` is `null` or doesn't exist, throw an error.
  - If the file extensions is `.jq`, it's a jq script: `./more/code-goes-here.jq` (for example).
  - If the file extension is `.json`, it's data: `../data/data-goes-here.json` (for example).
  - If the file extensions is anything else, throw an error.
- If nothing could be resolved, throw an error.

The resulting file `F` should now have been resolved, and the `import ...` statement can continue with file parsing.


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
- Using a subdirectory for the main jq file, `./jq/main.jq`, can be discussed. At least it separates code files from the ordinary readme/license/metadata file clutter.



## Original purpose

The library was built awaiting and expecting a complete jq package system, and to show how I expect the `import` statement to be used.


