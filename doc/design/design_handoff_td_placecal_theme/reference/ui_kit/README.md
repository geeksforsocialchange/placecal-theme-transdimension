# UI kit: The Trans Dimension on PlaceCal

Hash-routed recreation of transdimension.uk as served by PlaceCal with the `placecal-theme-transdimension` engine. Desktop (≥1200px) layout; the nav and footer components carry mobile variants.

Screens: Home (`#/`), Events (`#/events`), Event (`#/events/:id`), Partners (`#/partners`), Partner (`#/partners/:slug`), News (`#/news`), Article (`#/news/:slug`), About (`#/about`), Join us (`#/join`).

Interactions: nav + footer links, region filter (Everywhere/London/Manchester) shared across Home/Events/Partners, day strip, event/partner/article click-through, Join form submit.

Files: `data.jsx` (sample events/partners/articles — copy from the live site and locales), `Shell.jsx` (inner-page chrome: nav, illustration bands, wordmark, title, footer), `Home.jsx`, `Events.jsx`, `Partners.jsx`, `News.jsx`, `Pages.jsx` (About, Join), `App.jsx`.

Maps are drawn as a pink placeholder in the map's colours — the real site uses a pink-tinted OpenFreeMap style. Article photos are stock placeholders.
## Modes

A switch (bottom right, persisted) toggles **Live site** (faithful port of transdimension.uk) and **Final (PlaceCal)** — the consolidated design in `Final.jsx`:

- Nav: region selector moves into the bar as a segmented control beside "Donate"; "Join us" stays in the footer.
- Events: day strip with earlier/later arrows (no Past/Future buttons); "Filter and sort" toolbar of TD selects (Neighbourhood, Category, Repeating, Sort) with a live count; neighbourhood Badge in the card title row; iCal / CSV / permalink buttons under the list.
- Event: byline in the title panel; icon-led details row with Add to calendar / Share; contact, address and organiser columns with per-row icons; a pointer to the partner's accessibility info; map; "Problem with this listing?".
- Partners: Category / Neighbourhood / Sort toolbar; partner page gets Visit / Email / Call buttons, Accessibility block, opening times, and its own events list with iCal/CSV.
- News: "From" partner filter, Previous / 1 2 3 / Next pagination; article gets Share / More from partner / Back to news.

## Page titles on show pages

Listing pages keep the starfield `h1` (Events / Partners / News). Show pages (event, partner, article) drop it: the entity name in the pink panel is the page's only `h1` (one `h1`, matching `<title>`/OG — better for SEO and screen readers). Section context comes from the nav underline plus a light allcaps "← All partners" link where the title used to be. In the PlaceCal theme this is: hide core's `.hero` kicker on `Views::Partners::Show` / `Events::Show`; the name is already the `h1`.
