<p align="center">
  <a href="https://github.com/joelpurra/jqnpm"><img src="https://rawgit.com/joelpurra/jqnpm/master/resources/logotype/penrose-triangle.svg" alt="jqnpm logotype, a Penrose triangle" width="100" border="0" /></a>
</p>

# [jqnpm](https://github.com/joelpurra/jqnpm) - [jq](https://stedolan.github.io/jq/) package manager

A package manager built for the command-line JSON processor [`jq`](https://stedolan.github.io/jq/) as an example implementation. This is experimental software. [Want to contribute?](https://github.com/joelpurra/jqnpm/blob/master/CONTRIBUTE.md)


## Features

- Uses only namespaced packages, for example [`joelpurra/jq-stress`](https://github.com/joelpurra/jq-stress).
- Uses github.com by default; the example package would automatically be cloned from [`github.com/joelpurra/jq-stress`](https://github.com/joelpurra/jq-stress).
- Uses strict [semantic versioning](http://semver.org/) tags.
- Run `jqnpm generate` to autmatically create a package skeleton with:
  - `jq/main.jq` for your code.
  - `tests/all.sh` for easy-to-write tests.
  - `README.md` where you only need to fill in a usage example.
  - and `jq.json` with your package metadata.
- Code meant to only *consume* other packages are also called projects. They can use `jqnpm generate` file as well.



## Packages

See the [list of packages in the `jqnpm` wiki](https://github.com/joelpurra/jqnpm/wiki).



## Get it

- Clone the repository and add `src/` to your `$PATH`.
- Requirements:
  - [jq](https://stedolan.github.io/jq/) 1.5rc1+ in your `$PATH`. See the [`stedolan/jq` master branch](https://github.com/stedolan/jq/). Tested with [jq-1.5rc1-4-g6e7cf81 (6e7cf81)](https://github.com/stedolan/jq/commit/6e7cf81d74f98c3c467371172906d9009009f8a0), which is not yet *fully* compatible with `jqnpm`.
  - [bash](https://www.gnu.org/software/bash/) 4+, [git](http://git-scm.com/), [shUnit2](https://code.google.com/p/shunit2/).

```
git clone git://github.com/joelpurra/jqnpm.git
export PATH="$PATH:$PWD/jqnpm/src"
```



## Usage

Also see each source file, but don't expect much documentation yet.

#### Commands


```text
jqnpm <action> [options]

Actions:
  help
    Show this help.

  initialize
    Create default jq.json and jq/main.jq files.

  fetch [package]
    Preload package cache from remote server.

  install [package]
    Install/add jq.json dependencies to the current directory.

  execute [flags for jq]
    Run normal jq with dependencies. **This is a workaround until plain jq is up to speed.**

  generate <github username> <package name> "<one sentence to describe the package>"
    Generate a jq/jqnpm package skeleton in a subfolder.
    Package name: all lowercase, separate words with a dash '-'.
    Package name example: cool-tool
```


#### Example command line usage

```shell
cd my-project/                        # Your project.
jqnpm init                            # (optional) Create jq.json and jq/main.jq.
jqnpm install joelpurra/jq-stress     # Also creates a minimal jq.json.

# 'jqnpm execute' is a wrapper around jq, which also loads dependencies managed by jqnpm.
# **'jqnpm execute' is a workaround until plain jq is up to speed.**
# Write code in 'jq/main.jq' and use the way you would use jq, including flags:
# Example A:
echo '{ "hello": "world" }' | jqnpm execute # Will execute code in 'jq/main.jq'

# Example B:
jqnpm execute -n # Will execute code in 'jq/main.jq'

# Example C:
<"input.json" jqnpm execute --slurp >"output.json"  # Will execute code in 'jq/main.jq'
```


### `jq/main.jq`

Example usage combining two other packages.

```jq
import "joelpurra/jq-zeros" as Zeros;
import "joelpurra/jq-dry" as DRY;

def fib($n):
    [ 0, 1 ]
    | DRY::repeat(
        $n;
        [
            .[1],
            (
                .[0]
                + .[1]
            )
        ]
    )
    | .[0];

# Get the eighth Fibonacci number, pad it to four (integer) digits.
fib(8)
| Zeros::pad(4; 0)
```



## Creating a package

It's easy to create and publish a package of your own. Share your code!


### Guidelines

- The smaller package scope the better - it improves reusability through modularity.
- One piece of functionality per package - *each package does only one thing, but does it well*.
- The [new github repository](https://github.com/new) name should start with `jq-`, be all lowercase and words are separated by dashes: `jq-good-tool`. The `jq-` prefix is to make it easier for others to see which of your repositories are jq packages.
- The jq package name is written in `jq.json`. It is all lowercase and words are separated by dashes: `good-tool`. Note that there is no `jq-` prefix, as `jq.json` already knows it's package for jq.
- Author information, software license and project links are written in `jq.json` - see the [larger jq.json example](https://github.com/joelpurra/jqnpm/blob/master/BUILDING.md#larger-jqjson-example).


### Steps


1. Create a [new github repository](https://github.com/new):
  - Choose a name starting with `jq-`, similar to `jq-good-tool`.
  - Choose the MIT license if you don't have any other preference.
1. On your computer, run `jqnpm generate <github username> <package name> \"<one sentence to describe the package>\"`:
  - `<github username>` should be obvious.
  - `<package name>` is the same as the git hub repository you just created, for example `jq-good-tool`.
  - `\"<one sentence to describe the package>\"` is something snappy, like "This tool solves the worlds problems and can, contrary to a knife, only be used for good!"
1. Push the code to github:
  - `git commit`
  - `git push`
  - `git tag -a v0.1.0 -m v0.1.0 && git push origin v0.1.0"` (assuming your package version is `0.1.0`.)
1. Tell the world about it!



## Additional features

- Dependencies are stored in `./.jq/packages/` per package.
- A local cache in `~/.jq/` stores remote repositories.
- No *centrally managed* server side package repository is needed to publish your packages - just create a repository on github!
- As packages are stored on [github.com](https://github.com/) (by default), an account there is required for `jqnpm`. Because github allows private repositories, you can use `jqnpm` for private packages; this has not been tested yet.
- Can also use bitbucket and other online services, where usernames or organization names act as namespaces.



---

## License
Copyright (c) 2014, 2015, Joel Purra <http://joelpurra.com/>
All rights reserved.

When using **jqnpm**, comply to at least one of the three available licenses: BSD, MIT, GPL.
Please see the LICENSE file for details.


