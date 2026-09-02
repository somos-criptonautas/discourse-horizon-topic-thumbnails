// `thumbnails` is Discourse's topic.thumbnails array. Index 0 is the original
// upload; the rest are the sizes declared in about.json.
//
// We display the original. The cell is only `thumbnail_size` wide, but it fills
// the height of the card and is cover-cropped, so on a retina screen it needs
// far more pixels than its width suggests -- the generated sizes top out well
// below that and get upscaled into mush. The browser downscales the original
// for free; the generated sizes still have to be declared in about.json or
// Discourse does not serialize `topic.thumbnails` at all.
export function pickThumbnail(thumbnails) {
  const original = thumbnails?.[0];

  if (!original?.url) {
    return null;
  }

  return {
    src: original.url,
    width: original.width,
    height: original.height,
  };
}

// Theme list settings arrive as a "1|2|3" string.
export function parseCategoryIds(value) {
  return (value ?? "")
    .split("|")
    .filter(Boolean)
    .map((id) => parseInt(id, 10));
}

// List-level scoping, same semantics as the official Topic List Thumbnails
// component: an empty allow-list means every list, otherwise only lists being
// viewed *within* one of the chosen categories. Subcategories are not implied.
export function enabledForCategory(categoryId, allowed) {
  if (!allowed.length) {
    return true;
  }
  return allowed.includes(categoryId);
}
