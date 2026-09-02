// node scripts/thumbnail-source.test.mjs
import assert from "node:assert/strict";
import {
  enabledForCategory,
  parseCategoryIds,
  pickThumbnail,
} from "../javascripts/discourse/lib/thumbnail-source.js";

const full = [
  { max_width: null, url: "orig.png", width: 1600, height: 1200 },
  { max_width: 100, url: "a100.png" },
  { max_width: 400, url: "a400.png" },
];

// --- pickThumbnail ---

// no thumbnails -> render nothing (placeholder path)
assert.equal(pickThumbnail(null), null);
assert.equal(pickThumbnail([]), null);
assert.equal(pickThumbnail(undefined), null);

// always the original upload, never a generated size: the cell fills the card
// height and cover-crops, so the small sizes get upscaled and look soft
const picked = pickThumbnail(full);
assert.equal(picked.src, "orig.png");
assert.equal(picked.width, 1600);
assert.equal(picked.height, 1200);

// original with no url yet -> nothing rather than a broken image
assert.equal(pickThumbnail([{ max_width: null, url: null }]), null);

// --- parseCategoryIds ---

assert.deepEqual(parseCategoryIds(""), []);
assert.deepEqual(parseCategoryIds(undefined), []);
assert.deepEqual(parseCategoryIds("4"), [4]);
assert.deepEqual(parseCategoryIds("4|17|23"), [4, 17, 23]);

// --- enabledForCategory ---

// empty allow-list: every list, including /latest (no category)
assert.equal(enabledForCategory(4, []), true);
assert.equal(enabledForCategory(undefined, []), true);

// non-empty allow-list: only the listed categories
assert.equal(enabledForCategory(4, [4, 17]), true);
assert.equal(enabledForCategory(9, [4, 17]), false);

// /latest and /top have no category, so they are excluded once scoped
assert.equal(enabledForCategory(undefined, [4, 17]), false);

// a subcategory is not covered by its parent being listed
assert.equal(enabledForCategory(31, [4]), false);

console.log("ok - thumbnail-source");
