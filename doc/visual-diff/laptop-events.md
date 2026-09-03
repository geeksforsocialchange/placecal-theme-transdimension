# Laptop pass: /events

WP 3.8. Golden `https://transdimension.uk/events`, 1440px unless stated. Method in
`laptop-news.md`. The page chrome rows (header, page title, intro panel, footer) are in
`laptop-news.md` and are not repeated here.

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| page title | height | 365 | 348 | 365 | fixed (shared) |
| intro panel | y / height | 476 / 114 | 487 / 115 | 475 / 115 | fixed (shared) |
| "All events" heading | exists | no | yes, 35.2px, full width, between the panel and the box | removed | fixed |
| content box | first child y | 622 | 752 | 638 | mostly fixed |
| region filter | button x positions | 494, 650, 806 | 494, 650, 806 | same | matched |
| region filter | button width | 140 | 140 | 140 | matched |
| region filter | button height | 41 | 39 | 39 | residual, 2px |
| day strip | x / width | 209 / 1022 | 178 / 1084 | 178 / 1084 | residual, 31px, see below |
| event card | x / width | 178 / 526 | 178 / 526 | 178 / 526 | matched |
| event card | date column width | 76, no gutter | 72 plus a 16px gutter | 76, no gutter | fixed |
| event card title | x / width | 254 / 450 | 266 / 438 | 254 / 450 | fixed |
| event card title | font | 24 / 30.03 italic 500 | same | same | matched |
| event card detail lines | font | 19.2 / 28 | 19.2 / 28 | same | matched |
| event card | height | 182 (article 132) | 184 | 160 | residual, content |

## Residuals

- **The "All events" heading is gone.** Events.elm has no heading between the intro panel
  and the list, and core's heading sat outside the content box, breaking the pink border
  and pushing the filters 130px down the page. The `events.index.list_heading` override
  key is still there and still reaches the DOM for screen readers; only the box on the
  page is hidden. If Kim wants a visible heading it needs to be inside the box, which is
  a core markup question (see partners, where the heading is inside).
- **Content box first child at 638 against 622** (16px). Our filter block carries a 16px
  gutter the live site does not; left as is because chasing it moves the shared box
  inset that every listing uses.
- **Day strip is 1084 wide, the live site's 1022.** Ours runs the full inner width of the
  box; the live site insets it by another 31px. Under the visible threshold once the
  buttons wrap, and the button rows land in the same place.
- **"Filter and sort" disclosure and the rule under it** are PlaceCal's own controls; the
  live site has no equivalent. Existing deviation, not introduced here.
- **Card height 160 against 182**: our seeded events carry one detail line fewer than the
  live site's. Content.
