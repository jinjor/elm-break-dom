# elm-break-dom

[![Netlify Status](https://api.netlify.com/api/v1/badges/be3da983-1d1e-4c84-a596-ab4597c31027/deploy-status)](https://app.netlify.com/sites/elm-break-dom/deploys)
[![Build Status](https://travis-ci.org/jinjor/elm-break-dom.svg?branch=master)](https://travis-ci.org/jinjor/elm-break-dom)

Tests for [this issue](https://github.com/elm/html/issues/44).

- Aims to make this tests successful with the latest `elm/html`.
- Visit [elm-break-dom.netlify.com](https://elm-break-dom.netlify.com/) with problematic extensions enabled/disabled.

## Test locally

Install.

```shell
npm install
```

Run basic tests (automatically with puppeteer).

```shell
npm test
```

Run extension tests (manually with your chrome).

```shell
npm run test:extensions # Note: some extensions work only on served pages
```
