# elm-break-dom

[![Build Status](https://travis-ci.org/jinjor/elm-break-dom.svg?branch=master)](https://travis-ci.org/jinjor/elm-break-dom)
[![Netlify Status](https://api.netlify.com/api/v1/badges/be3da983-1d1e-4c84-a596-ab4597c31027/deploy-status)](https://app.netlify.com/sites/elm-break-dom/deploys)

Elm's Virtual DOM does not work well with Chrome extensions ([Issue](https://github.com/elm/html/issues/44)).
This repository aims to resolve it by following process.

- Gather information about how extensions break DOM (insert, wrap, etc.)
- Make a patch for `elm/virtual-dom`
- Try [online](https://elm-break-dom.netlify.com/) with problematic extensions enabled/disabled

## Known Extensions

This table describes where and when an element is inserted, thanks to the discussion in the [discourse thread](https://discourse.elm-lang.org/t/runtime-errors-caused-by-chrome-extensions/4381). More informarion is still welcome.

| Plugin (Users)                        | Where in `<body>`      | When                     | Workaround (keep enabled)                                                  | Workaround (disable)                                     |     |
| :------------------------------------ | :--------------------- | :----------------------- | :------------------------------------------------------------------------- | :------------------------------------------------------- | :-- |
| [Google Translate][gtr] (10,000,000+) | **middle**             | translate the page       |                                                                            | `<meta name="google" content="notranslate">` in `<head>` |
| Google Translate                      | bottom                 | select words             | [rough patch][patch], use `Browser.element`                                |                                                          |
| [Grammarly][grammarly] (10,000,000+)  | **middle**             | focus on `<textarea>`    |                                                                            | [`data-gramm_editor="false"`][w-grammarly]               |
| [Dark Reader][dark] (1,763,020)       | **middle (sometimes)** | load                     | [make `<style>` the last child][w-dark], avoid using `<style>` in `<body>` |                                                          |
| [ChromeVox][chrome-vox] (161,918)     | top                    | load, focus on something | [rough patch][patch], use `Browser.element`                                |                                                          |
| [Viber][viber] (133,220)              | top, bottom            | load                     | [rough patch][patch], use `Browser.element`                                |                                                          |

[gtr]: https://chrome.google.com/webstore/detail/google-translate/aapbdbdomjkkjkaonfhkkikfgjllcleb
[grammarly]: https://chrome.google.com/webstore/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen
[dark]: https://chrome.google.com/webstore/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh
[chrome-vox]: https://chrome.google.com/webstore/detail/chromevox-classic-extensi/kgejglhpjiefppelpmljglcjbhoiplfn
[viber]: https://chrome.google.com/webstore/detail/viber/dafalpmmoljglecaoelijmbkhpdoobmm
[w-grammarly]: https://github.com/elm/html/issues/44#issuecomment-534665947
[w-dark]: https://github.com/mdgriffith/elm-ui/commit/02e9919a47d50a71fbc92338a8a38def853ffa0f
[patch]: #patch-for-browserapplication

Note:

- For "Where in `<body>`" Column, `top` and `bottom` breaks `Browser.application` and `middle` breaks both `Browser.application` and `Browser.element`. `middle` contains modifications to all descendant elements in the `<body>`.
- Some of the extensions insert elements in `<head>` or _after_ `<body>`. They are excluded from this list because it has no harm.

## Test patched VirtualDOM

You can test the patched version of `elm/virtual-dom`. About the patch, see more details [here](./patch).

### Install

```shell
npm install
```

### Build

```shell
npm run build
```

This will build:

- patched version of `elm/virtual-dom`
- `simple.js` from `src/` using the original version
- `simple-patched.js` from `src/` using the patched version

### Auto test

```shell
npm test
```

This test uses puppeteer and breaks DOM in various patterns without real Chrome extensions.

For each test case,

- An element is inserted/removed via ports when a button is clicked.
- Elm will update Virtual DOM.
  See the [source](./src/Main.elm) to find where in the DOM is updated in each case.

### Manual test

```shell
npm run test:extensions
```

This test coveres problematic cases of well-known extensions.

Since this test uses the real extensions, it cannot be covered by puppeteer.
You need to see the result on your Chrome.
Turn on and off the your extensions to see how the results change.

## Appendix: Hacky patch for `Browser.application`

Here is a simple patch (thanks to [a discourse comment](https://discourse.elm-lang.org/t/fullscreen-elm-app-in-0-19-childnode-issue-reopened/3174/2)) for `Browser.application`.

```shell
root_id=root # Note: <div id="$root_id"> must exist before Elm.Main.init()
cat elm.js\
  | sed "s/var bodyNode = _VirtualDom_doc.body;/var bodyNode = _VirtualDom_doc.getElementById('$root_id');/"\
  | sed "s/var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.body);/var nextNode = _VirtualDom_node('div')(_List_Nil)(doc.body);/"\
  > elm-patched.js
```

Note: This is just a workaround, _NOT_ a fix. For `Browser.application`, the root should be always `<body>` element. This is [by design](https://github.com/elm/browser/blob/1.0.0/notes/navigation-in-elements.md).
Note: This will be no use once [this patch](./patch/README.md) is merged.
