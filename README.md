# elm-break-dom

[![Build Status](https://travis-ci.org/jinjor/elm-break-dom.svg?branch=master)](https://travis-ci.org/jinjor/elm-break-dom)
[![Netlify Status](https://api.netlify.com/api/v1/badges/be3da983-1d1e-4c84-a596-ab4597c31027/deploy-status)](https://app.netlify.com/sites/elm-break-dom/deploys)

Tests for [this issue](https://github.com/elm/html/issues/44).

- Aims to make this tests successful with the latest `elm/html`.
- Visit [elm-break-dom.netlify.com](https://elm-break-dom.netlify.com/) with problematic extensions enabled/disabled.

## Test locally

### Install

```shell
npm install
```

### Run simple tests (automatically with puppeteer)

```shell
npm test
```

In this test, Elm is setup with `Browser.element` and assumes that no Chrome extensions are installed.
For each test case,

- An element is inserted/removed via ports when a button is clicked.
- Elm will update Virtual DOM.
  See the [source](./src/Main.elm) to find where in the DOM is updated in each case.

If you want manual testing, run `npm run build` and open `public/simple.html`.
(Note: You cannot test after an error is thrown. Reload to test another.)

### Run extension tests (manually with your chrome)

```shell
npm run test:extensions
```

In this test, Elm is setup both with `Browser.application` and with `Browser.element`.
Turn on and off your extensions to see how the results change.

(Note: You cannot open `public/index.html` directly, because `Browser.application` can only work on served pages. Some extensions also have this limitation.)

## Known Plugins

Describing where and when an element is inserted.

| Plugin (Users)               | Where                       | When                     | Workaround                        |
| :--------------------------- | :-------------------------- | :----------------------- | :-------------------------------- |
| [Grammarly][1] (10,000,000+) | **middle in `<body>`**      | focus on `<textarea>`    | [`data-gramm_editor="false"`][p1] |
| [ChromeVox][2] (161,918)     | **top in `<body>`**         | load, focus on something | [patch to output][p2]             |
| [Viber][3] (133,220)         | **top, bottom in `<body>`** | load                     | [patch to output][p2]             |

[1]: https://chrome.google.com/webstore/detail/grammarly-for-chrome/kbfnbcaeplbcioakkpcpgfkobkghlhen
[2]: https://chrome.google.com/webstore/detail/chromevox-classic-extensi/kgejglhpjiefppelpmljglcjbhoiplfn
[3]: https://chrome.google.com/webstore/detail/viber/dafalpmmoljglecaoelijmbkhpdoobmm
[p1]: https://github.com/elm/html/issues/44#issuecomment-534665947
[p2]: ./build.sh
