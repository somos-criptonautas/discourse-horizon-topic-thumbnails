import Component from "@glimmer/component";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import {
  enabledForCategory,
  parseCategoryIds,
  pickThumbnail,
} from "../lib/thumbnail-source";

const ENABLED_CATEGORIES = parseCategoryIds(settings.enabled_categories);

class ThumbnailCell extends Component {
  @service discovery;

  get image() {
    return pickThumbnail(this.args.topic?.thumbnails);
  }

  // Category scoping is decided here, per render, not when the column is
  // registered: core builds the `topic-list-columns` context from
  // `topicTrackingState.filterCategory` (often undefined) and caches the
  // resolved columns per list instance, so it does not see a route change.
  // `discovery.category` is the route's actual category.
  get inScope() {
    return enabledForCategory(this.discovery.category?.id, ENABLED_CATEGORIES);
  }

  // Out of scope, or nothing to show: collapse the cell so the card runs the
  // full width of the row.
  get isEmpty() {
    return !this.inScope || (!this.image && !settings.placeholder_icon);
  }

  <template>
    <td
      class="htt-thumbnail-cell
        {{if this.isEmpty 'htt-empty'}}
        {{if this.inScope 'htt-scoped'}}"
    >
      {{#if this.isEmpty}}
        {{! nothing }}
      {{else if this.image}}
        <img
          src={{this.image.src}}
          width={{this.image.width}}
          height={{this.image.height}}
          loading="lazy"
          alt=""
          aria-hidden="true"
        />
      {{else if settings.placeholder_icon}}
        <span class="htt-placeholder" aria-hidden="true">
          {{dIcon settings.placeholder_icon}}
        </span>
      {{/if}}
    </td>
  </template>
}

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");

  document.documentElement.style.setProperty(
    "--htt-size",
    `${parseInt(settings.thumbnail_size, 10)}px`
  );

  api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns }) => {
      // Horizon forces the desktop column layout on mobile for card contexts, so
      // this column would otherwise render on phones too. Its edge-to-edge mobile
      // card (full-bleed footer, horizontally scrolling tag strip) does not
      // survive being squeezed into a narrower row, so stay out by default.
      if (site.mobileView && !settings.mobile_thumbnails) {
        return columns;
      }

      // Only Horizon's high context layout registers this column. Simple cards
      // (suggested / related lists) and non-Horizon themes never match, so we
      // never render a stray cell.
      if (!columns.has("high-context-card")) {
        return columns;
      }

      // Column items render as direct children of the <tr>, so this lands as a
      // real sibling of Horizon's <td class="hc-topic-card">.
      columns.add(
        "htt-thumbnail",
        { item: ThumbnailCell },
        { before: "high-context-card" }
      );

      return columns;
    }
  );
});
