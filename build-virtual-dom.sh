#!/bin/bash

set -e
cd `dirname $0`

elm_version=`elm --version`
author=elm
package=virtual-dom
repo=https://github.com/$author/$package.git
ELM_HOME=`pwd`

# setup
if [ ! -e $package ]; then
  git clone $repo
  rm -rf $package/.git
  ln -s $package/src/Elm/Kernel Kernel
  cp Kernel/VirtualDom.js Kernel/original_VirtualDom.js
  # apply the latest patch
  patch -u -p0 < patch/VirtualDom.patch
fi

# save current patch
diff -u Kernel/original_VirtualDom.js Kernel/VirtualDom.js > patch/VirtualDom.patch || true

# build patched virtual-dom
pushd $package
version=`cat elm.json | jq -e .version | tr -d '"'`
rm -rf ./elm-stuff
elm make --docs=documentation.json
popd

# reset $ELM_HOME cache for next `elm make`
target_dir=$ELM_HOME/$elm_version/package/$author/$package/$version
rm -rf $target_dir
mkdir -p $target_dir
cp -r $package/* $target_dir