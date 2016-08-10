# CartfileDiff 
[![Build Status](https://travis-ci.org/YPlan/CartfileDiff.svg?branch=master)](https://travis-ci.org/YPlan/CartfileDiff)

`cartfilediff` is a simple tool for comparing two `Cartfile.resolved` files and printing a list of dependencies in the latter which are new or differ in pinned version.

## Faster `carthage bootstrap`

Building dependencies from source with Carthage can be time consuming, especially for large projects or on slower hardware. Carthage does not currently figure out which dependencies need rebuilding when running `carthage bootstrap` which can result in lengthy build times, even if only one dependency needs rebuilding.

In combination with a cache, you can use `cartfilediff` to dramatically speed up your CI builds. Store the Carthage build products and the `Cartfile.resolved` in the cache, and compare the cached `Cartfile.resolved` with the current `Cartfile.resolved` at the start of the build. Then run `carthage bootstrap` with the modified dependencies, if necessary:

```sh
#!/bin/bash

CACHED_CARTFILE="cache/Cartfile.resolved"

if [ -e "$CACHED_CARTFILE" ]; then
  OUTDATED_DEPENDENCIES=$(cartfilediff "$CACHED_CARTFILE" Cartfile.resolved)

  if [ ! -z "$OUTDATED_DEPENDENCIES" ]
  then
    echo "Bootstrapping outdated dependencies: $OUTDATED_DEPENDENCIES"
    carthage bootstrap "$OUTDATED_DEPENDENCIES"
  else
    echo "Cartfile.resolved matches cached, skipping bootstrap"
  fi
else
  echo "Cached Cartfile.resolved not found, bootstrapping all dependencies"
  carthage bootstrap
fi

```

## Installation

See [Releases](https://github.com/YPlan/CartfileDiff/releases) for prebuilt `pkg` installers.

Alternatively, clone this repository and run `make install`.

## Usage

`cartfilediff <old Cartfile.resolved> <new Cartfile.resolved>`

The tool prints a list of dependencies which need bootstrapping. If nothing needs bootstrapping, the tool prints nothing.

## License

CartfileDiff is released under the [MIT License](LICENSE.md).

## Acknowledgements

[Carthage](https://github.com/Carthage/Carthage), for providing the Carthage tool and for portions of source code used in this project.
