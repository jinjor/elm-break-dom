# Patch (WIP)

[This patch](./VirtualDom.patch) tries to solve the problem in the following way.

1. Mark the DOM node as `created_by_elm`
2. If unknown nodes have been inserted, skip them.
3. If existing nodes have been removed, re-create them by old vdom.
4. If existing nodes have been replaced with unknown nodes, re-create them by old vdom.

FYI, the VDOM processing is done with the following steps.

1. Diff old and new vdom node and collect patches
2. Link patches to a real DOM nodes
3. Apply patches

On the second process, each patch should not be tied with a wrong node which is inserted by Chrome extension.
Without this fix, patches are applyed to the wrong nodes and cause runtime errors.

## Current Status

This patch makes the [simple test](../test/test.js) all green (see the result [here](https://travis-ci.org/jinjor/elm-break-dom)), but it does not cover enough cases.

TODO includes:

- Insert / Remove many extension nodes
- Events from `<a>`
- `Html.Keyed`
- `Html.Lazy`
- Tests with real extensions
