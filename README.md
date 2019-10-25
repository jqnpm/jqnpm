<p align="center">
  <a href="https://github.com/joelpurra/jqnpm"><img src="https://raw.githubusercontent.com/joelpurra/jqnpm/master/resources/logotype/penrose-triangle.svg?sanitize=true" alt="jqnpm logotype, a Penrose triangle" width="100" border="0" /></a>
</p>

# [jqnpm](https://github.com/joelpurra/jqnpm) -- [jq](https://stedolan.github.io/jq/) package manager

A package manager built for the command-line JSON processor [`jq`](https://stedolan.github.io/jq/) as an example implementation. This is experimental software. [Want to contribute?](https://github.com/joelpurra/jqnpm/blob/master/CONTRIBUTE.md)

<p align="center">
  <a href="https://github.com/joelpurra/jqnpm/">
    <img src="https://cloud.githubusercontent.com/assets/1398544/5852881/aaefa09c-a21d-11e4-9e7b-7c2c5574e0b6.gif" alt="jqnpm in action" border="0" />
  </a>
</p>


- Uses only namespaced packages, for example `jqnpm install joelpurra/jq-stress`, on github.com by default; the example package would automatically be cloned from [`github.com/joelpurra/jq-stress`](https://github.com/joelpurra/jq-stress).
- Uses strict [semantic versioning](http://semver.org/) tags.
- Use the [packages in the `jqnpm` wiki](https://github.com/joelpurra/jqnpm/wiki) - it's easy to [create and publish a package of your own](https://github.com/joelpurra/jqnpm#creating-a-package). Share your code! &#x1f493;



## Installation

**On Mac with [Homebrew](http://brew.sh/)**

```bash
brew tap joelpurra/joelpurra
brew install jq
brew install jqnpm
```

**On other systems**

- Clone or download, then symlink `src/jqnpm`. There is no build step.
- Requirements: [jq](https://stedolan.github.io/jq/) 1.5+, [bash](https://www.gnu.org/software/bash/) 4+, [git](http://git-scm.com/), [shUnit2](https://github.com/kward/shunit2).


**Compatibility with `jq`**

- `jqnpm` was tested with jq-1.5, which is [not yet *fully* compatible with `jqnpm`](https://github.com/joelpurra/jqnpm/blob/master/CONTRIBUTE.md#requirements-for-the-jq-binary).
- For example deep package resolution doesn't work with plain `jq`. Without this feature, every dependency has to be installed in the package root.
- See also the [`jqnpm`'s `package-root` fork of `jq`](https://github.com/joelpurra/jq/tree/package-root), which fixes these issues.
- The easiest way to get both is to use `brew` to unlink both `jq` and `jqnpm`, then install the `jqnpm --devel` version which installs the patched versions.

```bash
brew tap joelpurra/joelpurra
brew unlink jqnpm
brew unlink jq
brew install jqnpm --devel
```


## Usage


```bash
jqnpm help
```


**Example 1**

These are the extended steps from the demo animation above.

```shell
# Your new project folder.
mkdir my-project
cd my-project/

# Create 'jq.json', 'jq/main.jq', the local '.jq/' folder.
jqnpm init

# Fetch package from github, installs it into '.jq/packages/'.
jqnpm install joelpurra/jq-stress

# Edit your 'jq/main.jq' file with your code.
echo 'import "joelpurra/jq-stress" as Stress; Stress::remove("e")' > jq/main.jq

# 'jqnpm execute' is a wrapper around jq, which also loads dependencies managed by jqnpm.
# **'jqnpm execute' is a workaround until plain jq is up to speed.**
echo '"Hey there!"' | jqnpm execute
```

**Example 2**

Example `jq/main.jq` combining two other packages; `jqnpm install joelpurra/jq-zeros && jqnpm install joelpurra/jq-dry`.

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

As this example doesn't expect to read any JSON data, execute it with `--null-input`/`-n` as you normally would with `jq`.

```shell
jqnpm execute --null-input
```



## Creating a package

How to create a package of your own, using `jqnpm generate`. Share your code! &#x1f493;


**Guidelines**

- The smaller package scope the better - it improves reusability through modularity.
- One piece of functionality per package -- *each package does only one thing, but does it well*.
- The [new github repository](https://github.com/new) name should start with `jq-`, be all lowercase and words are separated by dashes: `jq-good-tool`. The `jq-` prefix is to make it easier for others to see which of your repositories are jq packages.
- The jq package name is written in `jq.json`. It is all lowercase and words are separated by dashes: `good-tool`. Note that there is no `jq-` prefix, as `jq.json` already knows it's package for jq.
- Author information, software license and project links are written in `jq.json`.


**Steps**

1. Create a [new github repository](https://github.com/new):
  - Choose a name starting with `jq-`, similar to `jq-good-tool`.
  - Choose the MIT license if you don't have any other preference.
1. On your computer, run `jqnpm generate <github username> <package name> "<one sentence to describe the package>"`:
  - `<github username>` should be obvious.
  - `<package name>` is the same as the git hub repository you just created, for example `jq-good-tool`.
  - `"<one sentence to describe the package>"` is something snappy, like `"This tool solves the worlds problems and can, contrary to a knife, only be used for good!"`
1. Push the code to github:
  - `git commit`
  - `git push`
  - `git tag -a v0.1.0 -m v0.1.0 && git push origin v0.1.0` (assuming your package version is `0.1.0`.)
1. Tell the world about it!



---



## License

Copyright (c) 2014, 2015, [Joel Purra](http://joelpurra.com/). All rights reserved.

When using [**jqnpm**](https://github.com/joelpurra/jqnpm), comply to at least one of the three available licenses: BSD, MIT, GPL. Please see the LICENSE file for details.


