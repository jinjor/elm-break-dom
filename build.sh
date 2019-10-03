#!/bin/bash
set -eu
cd `dirname $0`

rm -rf public/js
npx elm make src/Simple/Element.elm src/Simple/Application.elm --output=public/js/simple.js
npx elm make src/Extensions/Element.elm src/Extensions/Application.elm --output=public/js/extensions.js

# patch to simple.js
patch -u -p0 -o public/js/simple-patched.js < patch/simple.patch

# another patch to extensions.js
root_id=root # Note: <div id="$root_id"> must exist before Elm.Main.init()
cat public/js/extensions.js\
  | sed "s/var bodyNode = _VirtualDom_doc.body;/var bodyNode = _VirtualDom_doc.getElementById('$root_id');/"\
  | sed "s/var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);/var nextNode = _VirtualDom_node('div')(_List_Nil)(doc.body);/"\
  > public/js/extensions-patched.js