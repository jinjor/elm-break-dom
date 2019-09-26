# elm-break-dom

[![Build Status](https://travis-ci.org/jinjor/elm-break-dom.svg?branch=master)](https://travis-ci.org/jinjor/elm-break-dom)
[![Netlify Status](https://api.netlify.com/api/v1/badges/be3da983-1d1e-4c84-a596-ab4597c31027/deploy-status)](https://app.netlify.com/sites/elm-break-dom/deploys)

Tests for Elm's Virtual DOM with Chrome extensions ([Issue](https://github.com/elm/html/issues/44)).

- Aims to make this tests successful with the latest `elm/html`.
- Visit [elm-break-dom.netlify.com](https://elm-break-dom.netlify.com/) with problematic extensions enabled/disabled.

## Test locally

### Install

```shell
npm install
```

### Build

```shell
npm run build
```

This will build two apps (simple.js and extensions.js).
Each of those will be built both with `Browser.application` and with `Browser.element`.

### Run simple tests (automatically with puppeteer)

```shell
npm test
```

This test breaks DOM in various patterns without real Chrome extensions.

For each test case,

- An element is inserted/removed via ports when a button is clicked.
- Elm will update Virtual DOM.
  See the [source](./src/Main.elm) to find where in the DOM is updated in each case.

If you want manual testing, run `npm run test:simple-manual`.
(Note: You cannot test after an error is thrown. Reload to test another.)

### Run extension tests (manually with your Chrome)

```shell
npm run test:extensions
```

This test coveres problematic cases of well-known extensions.

Since this test uses the real extensions, it cannot be covered by puppeteer.
You need to see the result on your Chrome.
Turn on and off the your extensions to see how the results change.

For the case of inserting elements into the top of `<body>`, you can try patched version too.

## Known Extensions

Describing where and when an element is inserted, thanks to the discussion in the [discourse thread](https://discourse.elm-lang.org/t/runtime-errors-caused-by-chrome-extensions/4381). More informarion is welcome.

| Plugin (Users)                        | Where in `<body>`      | When                     | Workaround                                               |
| :------------------------------------ | :--------------------- | :----------------------- | :------------------------------------------------------- |
| [Google Translate][gtr] (10,000,000+) | **middle**             | translate the page       | `<meta name="google" content="notranslate">` in `<head>` |
| Google Translate                      | bottom                 | select words             | [patch the output][patch]                                |
| [Grammarly][grammarly] (10,000,000+)  | **middle**             | focus on `<textarea>`    | [`data-gramm_editor="false"`][w-grammarly]               |
| [Dark Reader][dark] (1,763,020)       | **middle (sometimes)** | laod                     | [wrap `<style>` tag ][w-dark]                            |
| [ChromeVox][chrome-vox] (161,918)     | top                    | load, focus on something | [patch the output][patch]                                |
| [Viber][viber] (133,220)              | top, bottom            | load                     | [patch the output][patch]                                |

[gtr]: https://chrome.google.com/webstore/detail/google-translate/aapbdbdomjkkjkaonfhkkikfgjllcleb
[grammarly]: https://chrome.google.com/webstore/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen
[dark]: https://chrome.google.com/webstore/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh
[chrome-vox]: https://chrome.google.com/webstore/detail/chromevox-classic-extensi/kgejglhpjiefppelpmljglcjbhoiplfn
[viber]: https://chrome.google.com/webstore/detail/viber/dafalpmmoljglecaoelijmbkhpdoobmm
[w-grammarly]: https://github.com/elm/html/issues/44#issuecomment-534665947
[w-dark]: https://github.com/mdgriffith/elm-ui/commit/02e9919a47d50a71fbc92338a8a38def853ffa0f
[patch]: ./build.sh

Some of the extensions insert elements in `<head>` or _after_ `<body>`. They are excluded from this list because it has no harm.

## TODO

- Tests to cover `Html.Keyed` and `Html.Lazy`
- Tests with `--optimize`
- Better patch
- More extensions
