# Laptop pass: /

WP 3.8. Golden is `https://transdimension.uk/`, ours is the theme on this branch, both
measured at a 1440px viewport unless a row says otherwise. Method and the caveat about
the dev server are in `laptop-news.md`.

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| `main` | width | 1440 (full viewport) | 1150 (the listing column) | 1440 | fixed |
| page wrapper | x / width | 96 / 1248 | 241 / 958 | 96 / 1248 | fixed |
| intro panel | x / width / height | 208 / 1024 / 383 | 305 / 830 / 439 | 208 / 1024 / 383 | fixed |
| intro panel | margin-inline | 112 | 64 | 112 | fixed |
| strapline `h2` | x / width / height | 240 / 960 / 129 | 337 / 766 / 185 | 240 / 960 / 129 | fixed |
| strapline | font | 51.2 / 56.32, 500 | same | same | matched |
| intro paragraph | x / width | 352 / 736 | 449 / 542 | 352 / 736 | fixed |
| events panel | x / width | 96 / 1248 | 193 / 1054 | 96 / 1248 | fixed |
| events panel | margin-inline | 0 | -48 | 0 | fixed |
| "UPCOMING EVENTS" | x / width / font | 113 / 1214 / 19.2 700 | 210 / 1020 | 113 / 1214 / 19.2 700 | fixed |
| events grid | x / y / width | 113 / 1555 / 1214 | 210 / 1611 / 1020 | 113 / 1555 / 1214 | fixed |
| news panel | x / width | 208 / 1024 | 305 / 830 | 208 / 1024 | fixed |
| news panel | padding | 48px 16px 64px | 32px 16px 64px | 48px 16px 64px | fixed |
| "LATEST NEWS" | x / width | 225 / 990 | 322 / 796 | 225 / 990 | fixed |
| home news card | x / width / height | 225 / 990 / 234 | 322 / 796 / 296 | 225 / 990 / 239 | fixed |
| home news card image | size | 303x202 | 303x203 | 303x202 | fixed |
| home news card text column | x / width | 528 / 687 | (narrower) | 528 / 687 | fixed |
| "Read the rest" | x / size | 638 / 164x49 | (shifted) | 638 / 164x49 | fixed |
| "View all news" | x / size | 637 / 165x49 | (shifted) | 637 / 165x49 | fixed |

At 1728 the panels stop growing and centre on their own measure: intro and news at
x 373 width 982 (golden 373 / 982), events at x 273 width 1182 (golden 272 / 1184).
At 1250 no regression.

## Residuals

- **Events grid height 720 against 750** and **news card height 239 against 234**: the
  seeded events and article are not the live site's, so line counts differ. Content, not
  CSS.
- **The events grid keeps a 16px top margin the live site does not have.** The grid still
  starts at the same y (1555 on both) because the filter above it carries a 48px bottom
  margin on the live site, so this is invisible; left alone rather than chased.
