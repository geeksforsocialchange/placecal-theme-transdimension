# Visual diff: news, article, about, privacy, get in touch

Method as in home.md (1250px bands over `news__wide.png`, `news_greater_manchester_trans_organisers_fund__wide.png`, `about__wide.png`, `privacy__wide.png`, `join_us__wide.png`). Coordinator, 2026-09-03.

| Region | Page | Width(s) | Ours | Golden | Status | Category | Justification |
|---|---|---|---|---|---|---|---|
| Title, intro panel | news | 1250 | "News", "Updates & articles from our partners." | same | matches | | |
| Article card: underlined title, "Read the rest" button centred on the card's bottom edge, day-month-year date | news | 1250 | | | fixed | | core WP 1.16 keys plus theme overrides and CSS |
| Card byline | news | all | partner line then date line | "Partner • 14th January 2025" on one line | differs | core slot | core renders partners and date as separate elements; ordinal day not available on the index |
| Card excerpt | news | all | plain text | plain text | fixed | | core WP 1.17 strips markdown |
| Section name, full-width box, centred column, byline | article | 1250 | | | fixed | | author line hidden (TD shows partner and date only) |
| Byline on one line | article | all | date and partner on separate lines | one line | differs | core slot | as above |
| Header art | about | 1250 | generic band | About artwork (character bottom left) | differs | | theme: the `.page--about` band override is wired (core WP 1.17) but the About header image needs its own placement; follow-up |
| Intro panel with the site description | about | 1250 | full-width pink panel, 40px type | same | fixed | | the theme's About view renders it as the first paragraph and styles it |
| Body type | about, privacy | 1250 | 24px | 24px | fixed | | |
| Title and subtitle | privacy | 1250 | "Privacy Policy" plus the subtitle standfirst | same | fixed | | the theme's Privacy view renders the subtitle from the locale file |
| Page title | get in touch | all | "Get in touch" | "Join us" | differs | decision | Kim: use the get in touch page for now; partner join form is #3456 |
| Intro panel copy and width | get in touch | 1250 | TD's copy, full width, flush on the form box | same | fixed | | one paragraph where TD has a heading plus a line (single core key) |
| Form fields, placeholders, optional tags, boxed checkboxes | get in touch | all | PlaceCal's | TD's | differs | 4a deviation | "Join Us form: PlaceCal's Join fields" |
| Form labels | get in touch | 1250 | 1.1rem allcaps | same | fixed | | |
