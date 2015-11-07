shell-ci-build [![Build Status](https://travis-ci.org/caarlos0/shell-ci-build.svg?branch=master)](https://travis-ci.org/caarlos0/shell-ci-build)
==================

A submodule to lint your shell projects with shellcheck in travis.ci builds.

## Build

- The `install.sh` script will install shellckeck.
- The `build.sh` will lint all executable files with shellcheck, avoiding
Ruby, compdef and the like files. It will also ignore all files inside `.git`
directory and files of your `gitmodules`, if any.

## Usage

```sh
git submodule add https://github.com/caarlos0/shell-ci-build.git build
cp build/travis.yml.example .travis.yml
```

We also support Shippable:

```
cp build/shippable.yml.example .shippable.yml
```

Or tweak your `.travis.yml` to be like this:

```yml
language: bash
install:
  - ./build/install.sh
script:
  - ./build/build.sh
```

## Customizing

You might want to lint other files, to do that, you need your own
`build.sh` and a slight change in `.travis.yml` file.

Example (from  my [dotfiles](https://github.com/caarlos0/dotfiles)):

```sh
#!/usr/bin/env bash
set -eo pipefail
source ./build/build.sh
check "./zsh/zshrc.symlink"
```

```yml
language: bash
install:
  - ./build/install.sh
script:
  - ./build.sh
notifications:
  email: false
```

This will make travis ran the `build.sh` from this project first,
then, lint your custom files.

You can also override the `find_cmd` function, which returns a string
containing the `find` command to `eval`. Check the source or open an
issue if you have any problems.

## Updating

Update your projects is easy. Just run this:

```sh
git submodule update --remote --merge && \
  git commit -am 'updated shell-ci-build version' && \
  git push
```
