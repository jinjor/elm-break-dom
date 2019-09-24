#!/bin/bash
elm make src/Main.elm --output=public/js/elm.js
elm make src/Extensions.elm --output=public/js/extensions.js