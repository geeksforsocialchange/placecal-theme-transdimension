# Trans Dimension Golden Screenshots

A set of reference images capturing every public route on transdimension.uk at four responsive viewports (mobile, tablet, desktop, wide). These captures serve as the acceptance artifact for Phase 2 work packages evaluating the compatibility of the Elm Pages / Phlex / Rails refactor.

## Captured routes

Route identifiers used below (picked live 2026-09-02):

- Events: /events/416614, /events/417493, /events/485844
- News: /news/greater-manchester-trans-organisers-fund, /news/can-you-help-out-with-the-trans-dimension, /news/the-trans-dimension-is-now-in-manchester
- Partners: /partners/150, /partners/427, /partners/445
- Static pages: /, /about, /join-us, /privacy
- List pages with region filters: /events, /news, /partners (and region=london, region=manchester variants)

Total: 20 route patterns, 4 viewports each = 80 images.

## Recapture

From this repo root, run:

`bash goldens/capture.sh`

By default, images are saved to goldens/<YYYY-MM-DD>. To use a different output directory:

`bash goldens/capture.sh /path/to/output`

The script verifies PNG signatures (89 50 4E 47 header) and enforces a 20 KB minimum file size, halting if either check fails. Manifest validity is confirmed via Python JSON parsing.

## Manifest

manifest.json contains an array of capture metadata: url, path, viewport, width, file, captured_at (ISO 8601 UTC), bytes, and sha256. A manifest entry looks like:

```json
{
  "url": "https://transdimension.uk/events",
  "path": "/events",
  "viewport": "desktop",
  "width": 950,
  "file": "events__desktop.png",
  "captured_at": "2026-09-02T21:14:06Z",
  "bytes": 489000,
  "sha256": "..."
}
```

## Viewports

- mobile: 450px
- tablet: 650px
- desktop: 950px
- wide: 1250px

Window height is 4000px (tall enough to capture full-page scrolls in one image). Scrollbars are hidden.
