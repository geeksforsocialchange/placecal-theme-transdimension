# Laptop pass: /about and /get-in-touch

WP 3.8. Golden `https://transdimension.uk/about` and `/join-us`, 1440px unless stated.
Shared chrome rows are in `laptop-news.md`.

## /about

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| page title | y / height | 110 / 365 | 142 / 340 | 110 / 365 | fixed |
| page title | line-height | 74.4 (1.5) | 57.04 (1.15) | 74.4 | fixed |
| page title | padding | 275px 0 16px | 275px 0 8px | 275px 0 16px | fixed |
| intro panel | x / y / width / height | 146 / 476 / 1148 / 326 | 146 / 500 / 1148 / 266 | 146 / 476 / 1148 / 326 | fixed |
| intro panel | padding-block | 64 (16 padding plus 48 margin) | 34 | 64 | fixed |
| intro panel | measure | 838 | 886 | 838 | fixed |
| intro copy | font | 40 / 49.6, 500 italic | same | same | matched |
| body copy | font | 19.2 / 28.8 | 24 / 38.4 | 24 / 38.4 | **differs, flagged** |
| body copy | layout | two columns, 408 wide each, in an 848 measure | one 636 column, centred | unchanged | **differs, flagged** |

At 1250 and 1728 the title and panel match the live site exactly (panel 326 at 1250, 342
at 1728, same as golden).

### The About body is a two-column flow

The live site sets the About body in 19.2px on 28.8 and runs it as two 408px columns
inside an 848px measure, at 1250 as well as 1440 and 1728. Ours is a single 636px column
at 24px on 38.4. This is a real font difference, but changing only the size would give
19.2px type in a 636px measure, which matches neither, and the two-column flow would have
to go on `.markdown-content` where it would also catch the pink intro panel and the
headings. Left as it is for Kim to decide: it is a design change to a page that was signed
off at 1250 in an earlier pass (`doc/visual-diff/pages.md` records the body as "24px,
matches", which this measurement contradicts).

## /get-in-touch (live site: /join-us)

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| page title | height | 365 | 365 | 365 | matched |
| intro panel | y | 476 | 547 | 475 | fixed |
| intro panel | padding-block | 72 above, 40 below | 32 above, 32 below, plus a 40px margin | 72 above, 40 below | fixed |
| intro panel | measure | 838 | 1102 | 838 | fixed |
| intro copy | font | 40 / 49.6, 500 | 40 / 49.6, 500 | same | matched |
| intro panel | height | 238 | 163 | 261 | residual, content |
| form box | y | 714 | 711 | 736 | follows the panel |

## Residuals

- **Intro panel height 261 against 238**: the live site's panel carries a heading plus one
  line; core gives the theme a single key, so ours is one longer sentence that wraps to
  three lines in the same measure. Copy, not CSS. Already recorded as a core slot.
- **Form fields are PlaceCal's**, not TD's. Existing 4a deviation, unchanged.
