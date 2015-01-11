# Contribute to [jqnpm](https://github.com/joelpurra/jqnpm)

This is experimental software, so [feedback is most appreciated](https://github.com/joelpurra/jqnpm/blob/master/CONTRIBUTE.md)!



## Additional development requirements

- [shUnit2](https://shunit2.googlecode.com/) 2.1.x+ in your `$PATH`.



## Steps

1. Run `git clean -idX :/` to clean up any generated file. Use with care.
1. Create a new `git branch` where you add your changes.
1. Edit `src/jqnpm` with your changes
  - Follow current conventions to increase the chance of your patch being accepted.
1. Write additional tests in a subfolder to `tests/`.
  - Code with tests have a much, much higher chance of being accepted.
1. If you have changed code in `tests/*/package-source` subfolders, run `./tests/create-bundles.sh` to regenerate git `.bundle` files for tests.
1. Run tests with `./tests/all.sh`.
1. Repeat until your feature is done, well tested and all tests pass.
1. Create a pull request based on your new branch.


## Debugging


### `export JQNPM_DEBUG_LEVEL=5`

Set the `JQNPM_DEBUG_LEVEL` in your shell to get some debugging output.

- `0` fatal
- `1` errors
- `2` warnings
- `3` information
- `4` debug
- `5` verbose



### Override for the *temporary `jq` wrapper* `jqnpm execute`

If you are runnings tests agains plain `jq`, it used to be a hassle to replace `jqnpm execute`. Now it's easy.

```bash
cd tests/
echo 'jq "$@"' >"jq-command-override.sh"
chmod u+x "jq-command-override.sh"
```

Now you can run `./tests/all.sh` against `jq` instead of using the *temporary `jq` wrapper* `jqnpm execute` - it is not to be used once `jq` is up to speed.


### Custom remote server (or fake directory)

Remotes and cache can be changed for testing by setting some environment variables in your shell.


Default values

```bash
config_default_packagesCache="$HOME/.jq/packages"
config_default_remoteBase="git://github.com"
config_default_remoteSuffix=".git"
```


Values are used during most tests.

```bash
export JQNPM_PACKAGES_CACHE="${BASH_SOURCE%/*}/package-cache"
export JQNPM_REMOTE_BASE="${BASH_SOURCE%/*}/remote-base"
export JQNPM_REMOTE_SUFFIX=".bundle"
```


## Larger `jq.json` example.

This example has been removed in favor of generating a package skeleton with `jqnpm generate`.
