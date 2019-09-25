#!/bin/bash
npx elm make src/Main.elm --output=public/js/elm.js
npx elm make src/Element.elm src/Application.elm --output=public/js/extensions.js