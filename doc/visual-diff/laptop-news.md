# Laptop pass: /news

WP 3.8. Numbers are measured with a DevTools-protocol script against
`https://transdimension.uk/news` (golden) and `http://transdimension.lvh.me:3030/news`
(ours) at a 1440px viewport unless a row says otherwise. "Before" is the theme at
`main`; "after" is this branch. Anything over 4px, or any font difference, is flagged.

## Page chrome (shared with every page on the site)

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| `header` | height | 94 | 107 | 94 | fixed |
| `header nav` | height | 78 | 91 | 78 | fixed |
| nav `li` | padding | 16px 12px | 25px 12px 23px | 16px 12px | fixed |
| nav `li` | font-size | 19.2 | 17.6 | 19.2 | fixed |
| nav `a` | height / line-height | 32 / 28.8 | 30 / 24 | 32 / 28.8 | fixed |
| nav Donate pill | height / padding | 43 / 6px 20px 8px | 48 / 8px 20px | 43 / 6px 20px 8px | fixed |
| nav link x positions | x | 20, 95, 179 | 20, 95, 179 | 20, 95, 179 | matched |
| page title | line-height | 74.4 (1.5) | 57.04 (1.15) | 74.4 | fixed |
| page title | height / padding | 365 / 275px 0 16px | 348 / same | 365 | fixed |
| intro panel | y (top) | 475 | 487 | 475 | fixed (1rem top margin removed) |
| intro panel | height | 116 | 115 | 115 | matched |
| intro panel copy | font / measure | 40 / 49.6, max-width 838 | 40 / 49.6, 838 | same | matched |
| intro panel @1728 | height | 132 | 115 | 131 | fixed (extra padding-bottom over 1500px) |
| footer | line-height | 24 (1.5) | 22.4 (1.4) | 24 | fixed |
| footer nav | height | 58 | 89 | 58 | fixed (list margin removed) |
| footer nav `a` | font-size / line-height | 17.6 / 26.4 | 18 / 25.2 | 17.6 / 26.4 | fixed |
| footer legal lines | line-height | 18.08 | 15.87 | 18.08 | fixed |
| footer middle band | columns | 3 (social, credits, newsletter form) | 2, centred | 2, centred | residual: no newsletter form in core's footer slot; the two remaining columns stay centred (WP 2.9 decision) |
| footer | total height | 730 | 755 | not re-measured | the four footer fixes above were applied but the dev server went down before they could be re-measured; see the note at the end |

## Article cards

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| card | x / width | 260 / 920 | 260 / 920 | 260 / 920 | matched |
| card | height (2-line title) | 300 | 403 | 301 | fixed |
| card | padding | 32 | 32px 32px 40px | 32 | fixed |
| card | y of first card | 655 | 666 | 654 | fixed |
| card pitch (card 1 to card 2) | y delta | 380 | 466 | 381 | fixed |
| card image | size | 303x202 | 303x203 (1px white `.border`) | 303x202 | fixed |
| card image | margin | 16px 0 | 0 0 16px | 16px 0 | fixed |
| card image | display | block | inline (added a 7px line box under it) | block | fixed |
| text column | x / width | 628 / 519 | 628 / 501 (core's `.gi` gutter margin) | 628 / 519 | fixed |
| card title | font / style | 29.6 / 38.48 italic 400 | same | same | matched |
| card title | margin-bottom | 0 | 24.6 | 0 | fixed |
| byline | layout | one line: partner, bullet, date | two lines | one line | fixed (card grid gives the byline row its own columns) |
| byline | font-size | 16 / 24 semibold | 12.8 / 19.2 then 16 / 24 | 16 / 24 | fixed |
| byline | margin-top | 16 | 12.8 | 16 | fixed |
| excerpt | font | 19.2 / 28.8 | same | same | matched |
| excerpt | margin-top | 8 (16 measured gap) | 8 | 16 (gap 16) | fixed |
| excerpt | line count | 3 (about 130 characters) | 4 (core truncates at 200) | 3 (clamped) | part fixed, core slot for the real length |
| "Read the rest" | size / padding | 164x49 / 6px 20px 8px | same | same | matched |
| "Read the rest" | overhang below card | 15 | 25 | 16 | fixed |
| "Read the rest" | x | 654 | 638 | 638 | residual, see below |

## Residuals

- **Byline still reads "Partner. bullet date"** — core's `Views::News::Index` prints a
  full stop after the partner links. CSS cannot remove a bare text node; see
  `doc/core-slots-needed.md`.
- **Excerpt length** — core's `ArticlesHelper#article_summary_text` truncates at 200
  characters; the live site's summaries run to about 130. The theme clamps the
  paragraph to three lines so the card height matches, but the clamped text ends
  mid-sentence rather than at a word boundary. Core slot.
- **Button x is 638, golden is 654** — on the live site the button's wrapper starts at
  the card's left padding edge and is 32px wider than the card's content box, so the
  button lands 16px right of the card's centre. Ours is centred on the card. Deliberate:
  reproducing the live site's overflow artefact would look like a mistake.
- **Card height varies with the title** — golden's card is a fixed 300px because every
  live title fits two lines. Our seeded titles run to three lines, giving 340px cards.
  Content difference, not CSS.

## 1728 and 1250

Re-measured at both. At 1728 the content column stays 1150px wide on both sites and the
first card sits at y 670 (ours) against 671 (golden), height 301 against 300. At 1250 the
first card sits at y 654 against 655, same heights. No regression.

## Verification gap

The footer rows (line-height, nav band height, nav link type, legal line-height) were
edited and the CSS rebuilt, but the local dev server started returning 500 before they
could be re-measured: core's WP 3.9 merge added `PlaceCal::Theme#icons`, which lives in
`lib/` and so does not reload, and the running server predates it. Everything above the
footer rows was measured after the fix.
