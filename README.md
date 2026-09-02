# Horizon Topic Thumbnails

Adds topic thumbnails to Horizon's **high context topic cards**, on the left of the
card, without forking or editing the Horizon theme.

## How it works

Horizon's high context layout registers a single topic-list column,
`high-context-card`, whose item renders the whole card as one
`<td class="hc-topic-card">`. Core renders each column's item component as a direct
child of the `<tr>`, so this component registers its own column immediately *before*
Horizon's:

```js
columns.add("htt-thumbnail", { item: ThumbnailCell }, { before: "high-context-card" });
```

That gives a real `<td>` sibling of the card, and the row is laid out as a flex
container -- thumbnail left, card right, no absolute positioning.

`about.json` declares `modifiers.topic_thumbnail_sizes`, which is what makes the
server serialize `topic.thumbnails` at all. The component then displays
`thumbnails[0]` -- the **original upload** -- rather than one of those generated
sizes: the cell is narrow but fills the card's height and is cover-cropped, so on a
retina screen it needs far more pixels than its width suggests, and the generated
sizes get upscaled into mush. The browser downscales the original for free. The official Topic List Thumbnails component is
not required, and should not be installed alongside this one -- it fights Horizon's
card layout.

## Requirements

- Horizon theme with **high context topic cards** enabled
  (`/admin/config/upcoming-changes` -- on by default on recent versions)
- Site setting `create thumbnails` enabled

## Install

1. Admin -> Customize -> Themes -> **Components** -> Install -> *From a git repository*
   (or upload this directory as a `.zip`).
2. Open the **Horizon** theme -> Components -> add *Horizon Topic Thumbnails*.

Nothing in Horizon is touched. Removing the component fully reverts the change.

Newly declared thumbnail sizes are generated in the background, so existing topics
may show the placeholder for a while before their images appear.

## Settings

| Setting | Default | |
|---|---|---|
| `thumbnail_size` | `150` | Width of the thumbnail column in px; the image fills the card's height and is cropped to fit. |
| `mobile_thumbnails` | `false` | Show thumbnails on mobile. See below. |
| `placeholder_icon` | `comments` | Icon for topics with no image, so cards keep a uniform width. Any icon name works. Leave empty and those cards run full width instead. |
| `enabled_categories` | *(empty)* | Show thumbnails only while browsing these categories. Empty = every topic list. |

### Mobile

**Off by default.** Horizon forces its desktop column layout on mobile for card
contexts, so the thumbnail column would otherwise render on phones -- but the
mobile card is deliberately edge-to-edge (`padding: var(--space-4) 0`, a full-bleed
footer with a gradient overlay, and a horizontally scrolling tag strip), and none
of that survives being squeezed into a narrower row.

The gate is in JS, not CSS: on mobile the column is never registered, so there is
no extra `<td>` and the row is left exactly as Horizon renders it.

Turning `mobile_thumbnails` on gives a 72px thumbnail below Horizon's `sm`
breakpoint (40rem). Expect the card footer to sit oddly, since its full-bleed
treatment assumes the card spans the whole row.

### Category scoping

Scoping is **list-level**, matching the official component: with
`enabled_categories` set, thumbnails appear on `/c/<category>` for the chosen
categories and nowhere else -- `/latest` and `/top` have no category and are
excluded.

**Subcategories are not implied.** Listing a parent category does not enable its
children; add each subcategory explicitly. (If you want parents to cascade, that is
a two-line change in `enabledForCategory`.)

## Scope

The column is only registered when `high-context-card` is present. Suggested and
related topic lists use Horizon's simple card, and non-Horizon themes register no
such column, so neither gets a thumbnail cell at all.

## Test

```
node scripts/thumbnail-source.test.mjs
```

Covers srcset/src selection (missing thumbnails, un-generated resizes, display sizes
larger than anything the server produced) and the category allow-list.

## Known ceiling

Depends on three Horizon names: the column key `high-context-card`, and the classes
`--high-context` and `.hc-topic-card`. If Horizon renames any of them, thumbnails
silently stop rendering -- the card itself is unaffected. Fix is a rename in
`api-initializers/horizon-topic-thumbnails.gjs` and `common/common.scss`.
