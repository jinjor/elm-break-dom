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

This patch makes the [simple test](../test/test.js) all green (see the [result](https://travis-ci.org/jinjor/elm-break-dom) and [coverage](https://elm-break-dom.netlify.com/coverage/simple-patched.js.html)).

TODO includes:

- More assertions for each test case
- Insert / Remove many extension nodes
- Update event handler
- Use attributeNS
- Events from `<a>`
- Tests with real extensions
