# Horizon Topic Thumbnails

**ENGLISH** | [ESPAÑOL](README.es.md)

Maintained by Criptonautas. Not affiliated with or endorsed by Discourse (Civilized Discourse Construction Kit, Inc.).

Adds topic thumbnails to Horizon's **high context topic cards**, on the trailing edge
of the card, without forking or editing the Horizon theme.

| Desktop | Mobile |
|---|---|
| ![Thumbnails on Horizon cards, desktop](docs/screenshots/thumbnails-desktop.png) | ![Thumbnails as banners, mobile](docs/screenshots/thumbnails-mobile.png) |

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
container -- card first, thumbnail after it, no absolute positioning.
Swap the grid columns in `common/common.scss` (and the two `order` values for
phones) to put it on the left instead. On desktop the row is a grid, so the card's
footer runs full width under the image. With `compact_last_reply` on (the default),
Horizon's last-reply pill sits in that footer row, right before the reply and like
counts, instead of taking a line of its own; the counts then align with the image's
leading edge rather than the card's far edge, so they stay next to the pill.

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
| `thumbnail_size` | `240` | Width of the thumbnail column in px; the image fills the card's height and is cropped to fit. |
| `mobile_thumbnails` | `true` | Show thumbnails on mobile, as a banner above the card. See below. |
| `placeholder_icon` | `comments` | Icon for topics with no image, so cards keep a uniform width. Any icon name works. Leave empty and those cards run full width instead. |
| `hide_excerpt` | `false` | Hide the topic excerpt wherever thumbnails are shown. Off by default: without the excerpt a card is just its title. |
| `compact_last_reply` | `true` | Keep thumbnail cards shorter by reusing Horizon's last-reply pill. Desktop: the pill moves into the footer row, right before the reply and like counts. Mobile: it replaces the "posted ... by" line. See below. |
| `enabled_categories` | *(empty)* | Show thumbnails only while browsing these categories. Empty = every topic list. |

### Mobile

Horizon forces its desktop column layout on mobile for card contexts, so the
thumbnail column renders on phones too. Its mobile card is deliberately edge to
edge -- `padding: var(--space-4) 0`, a full-bleed footer with a gradient overlay,
a horizontally scrolling tag strip -- and none of that survives being squeezed
into a narrower row.

So don't squeeze it. Below Horizon's `sm` breakpoint (40rem) the row flips to
`flex-direction: column`: the thumbnail becomes a banner above the card and the
card gets the whole row width back, exactly as Horizon draws it. The banner is
inset by the same `var(--space-4)` Horizon gives the card's content on phones and
keeps the rounded corners, so it lines up with the title below it.

With `compact_last_reply` on (the default), cards with a last-reply pill drop
Horizon's two-line "posted ... by" header and show the pill in its place, to pay
for the banner's height. Topics without replies have no pill and keep the original
header, and status badges (solved, closed) stay. Turn it off to keep Horizon's
header and context line exactly as stock, on desktop and mobile alike.

`--htt-size` is the cell's flex-basis in both directions, so it is the column
width on desktop and the banner height on mobile (140px).

Set `mobile_thumbnails` to false to skip it: the gate is in JS, so the column is
never registered and the row is left byte-identical to stock Horizon.

### Category scoping

Scoping is **list-level**, matching the official component: with
`enabled_categories` set, thumbnails appear on `/c/<category>` for the chosen
categories and nowhere else -- `/latest` and `/top` have no category and are
excluded.

The check reads `discovery.category` from the cell at render time, *not*
`context.category` in the `topic-list-columns` transformer. Two reasons that
transformer cannot do it: core builds its context from
`topicTrackingState.filterCategory`, which is not the route's category and is
often undefined, and `TopicList#columns` is `@cached`, so the resolved column
set does not rebuild when you navigate between categories.

Out-of-scope cells render as `.htt-empty` (`display: none`), and the row only
becomes a flex container when a visible cell is present, so a scoped-out list is
laid out exactly as stock Horizon.

With `hide_excerpt` on, in-scope cells also carry `.htt-hide-excerpt`, whether or
not the topic has an image. That is what hides `.topic-excerpt` across an enabled
category -- keying it on scope rather than on the cell being visible keeps
imageless rows consistent with the rest of the list.

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
silently stop rendering -- the card itself is unaffected. The layout also places
the card's parts by their `.hc-topic-card__*` classes (header, content, context,
footer and its children); a rename there leaves that piece out of place. Fix is a rename in
`api-initializers/horizon-topic-thumbnails.gjs` and `common/common.scss`.

## License

MIT. See [LICENSE](LICENSE).

Text of this README under [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
