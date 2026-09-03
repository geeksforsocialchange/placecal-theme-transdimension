# Laptop pass: /events/:id, /partners/:slug, /news/:slug

WP 3.8. Golden `https://transdimension.uk/events/416614`, `/partners/150` and
`/news/greater-manchester-trans-organisers-fund`; ours `/events/123`,
`/partners/beachfront-community-garden` and the first article on our /news. 1440px unless
stated. Shared chrome rows are in `laptop-news.md`. All three pages use the same shell,
so they share one table.

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| title block above the panel | height | 365 | 350 | 365 | fixed |
| content wrapper | y | 475 | 460 | 475 | fixed |
| pink title panel (event) | y / height | 476 / 163 | 460 / 144 | 475 / 114 | fixed for the shell, height is content |
| pink title panel (partner) | y / height | 476 / 114 | 460 / 144 | 475 / 114 | fixed |
| panel title | font | 40 / 49.6, 500 | 38.4 / 48 | 40 / 49.6, 500 | fixed |
| panel title | x / width | 301 / 838 | 301 / 838 | 301 / 838 | matched |
| panel title | margin | 16px auto | 32px auto | 16px auto | fixed |
| panel padding | | 16px 24px | 16px 24px | same | matched |
| article title panel | y / height | 476 / 98 | 461 / 131 | 476 / 131 | fixed for the shell, height is content |
| article title | font | 40 / 49.6, 500 | 40 / 49.6, 500 | same | matched |

## Residuals

- **Event panel 114 against 163, article panel 131 against 98**: the live site's event
  title runs to two lines and its article title to one; ours are the other way round.
  Content, not CSS: the padding, measure and type now match line for line.
- **Byline on the article page is still two lines** (partner on one, date on the next)
  where the live site puts them on one. Same core slot as the news card byline, recorded
  in `doc/core-slots-needed.md`.
