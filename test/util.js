module.exports.mergeCoverageByUrl = function(coverage) {
  const merged = {};
  for (const entry of coverage) {
    if (!merged[entry.url]) {
      merged[entry.url] = entry;
    }
    merged[entry.url].ranges.push(...entry.ranges);
  }
  Object.values(merged).forEach(entry => {
    entry.range = convertToDisjointRanges(entry.ranges);
  });
  return Object.values(merged);
};

// https://github.com/GoogleChrome/puppeteer/blob/83c327a0f6b343865304059dd09323e4f8285217/lib/Coverage.js#L269
/**
 * @param {!Array<!{startOffset:number, endOffset:number, count:number}>} nestedRanges
 * @return {!Array<!{start:number, end:number}>}
 */
function convertToDisjointRanges(nestedRanges) {
  const points = [];
  for (const range of nestedRanges) {
    points.push({ offset: range.startOffset, type: 0, range });
    points.push({ offset: range.endOffset, type: 1, range });
  }
  // Sort points to form a valid parenthesis sequence.
  points.sort((a, b) => {
    // Sort with increasing offsets.
    if (a.offset !== b.offset) return a.offset - b.offset;
    // All "end" points should go before "start" points.
    if (a.type !== b.type) return b.type - a.type;
    const aLength = a.range.endOffset - a.range.startOffset;
    const bLength = b.range.endOffset - b.range.startOffset;
    // For two "start" points, the one with longer range goes first.
    if (a.type === 0) return bLength - aLength;
    // For two "end" points, the one with shorter range goes first.
    return aLength - bLength;
  });

  const hitCountStack = [];
  const results = [];
  let lastOffset = 0;
  // Run scanning line to intersect all ranges.
  for (const point of points) {
    if (
      hitCountStack.length &&
      lastOffset < point.offset &&
      hitCountStack[hitCountStack.length - 1] > 0
    ) {
      const lastResult = results.length ? results[results.length - 1] : null;
      if (lastResult && lastResult.end === lastOffset)
        lastResult.end = point.offset;
      else results.push({ start: lastOffset, end: point.offset });
    }
    lastOffset = point.offset;
    if (point.type === 0) hitCountStack.push(point.range.count);
    else hitCountStack.pop();
  }
  // Filter out empty ranges.
  return results.filter(range => range.end - range.start > 1);
}
