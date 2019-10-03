#!/bin/bash
set -eu
cd `dirname $0`

rm -rf public/js

rm -rf ./elm-stuff
npx elm make src/Simple/Element.elm src/Simple/Application.elm --output=public/js/simple.js
npx elm make src/Extensions/Element.elm src/Extensions/Application.elm --output=public/js/extensions.js
echo "built with original version"

./build-virtual-dom.sh
rm -rf ./elm-stuff
env ELM_HOME=`pwd` npx elm make src/Simple/Element.elm src/Simple/Application.elm --output=public/js/simple-patched.js
env ELM_HOME=`pwd` npx elm make src/Extensions/Element.elm src/Extensions/Application.elm --output=public/js/extensions-patched.js
echo "built with patched version"