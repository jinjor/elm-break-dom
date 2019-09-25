#!/bin/bash
npx elm make src/Main.elm --output=public/js/elm.js
npx elm make src/Extensions.elm --output=public/js/extensions.js