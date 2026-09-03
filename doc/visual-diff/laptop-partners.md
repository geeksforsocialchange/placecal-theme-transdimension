# Laptop pass: /partners

WP 3.8. Golden `https://transdimension.uk/partners`, 1440px unless stated. Shared chrome
rows are in `laptop-news.md`.

| Element | Property | Golden | Ours before | Ours after | Status |
|---|---|---|---|---|---|
| intro panel | y / total height | 476 / 395 | 475 / 370 | 475 / 396 | fixed |
| intro panel big line | y / measure | 548 / 838 | 527 / 838 | 548 / 838 | fixed |
| intro panel small line | y / measure | 745 / 892 | 717 / 838 | 745 / 892 | fixed |
| intro panel small line | font | 19.2 / 28.8 | 18 / 28 | 19.2 / 28.8 | fixed |
| "ALL PARTNERS" | x / y / height | 194 / 904 / 29 | 194 / 845 / 90 | 194 / 904 / 29 | fixed |
| "ALL PARTNERS" | font | 19.2 / 28.8, 700, uppercase, left | 35.2 / 42.24, centred | 19.2 / 28.8, 700, uppercase, left | fixed |
| partner cards | x positions | 194 and 736 | 194 and 736 | same | matched |
| partner card | width | 510 | 510 | 510 | matched |
| partner card | margin | 24px 16px | 24px 16px | same | matched |

At 1250 the intro panel and the heading land on exactly the same pixels as the live site
(panel 396 against 395, heading at x 99 y 904 on both). At 1728 the panel is 412 against
411 after the widest-screen padding rule was added.

## Residuals

- **"ALL PARTNERS" sits 8px further in at 1728** (338 against 330): the box inset changes
  at the 1500px breakpoint on both sites but not by the same amount. Under the threshold.
- **Card heights vary with the seeded partner names and summaries.** Content.
