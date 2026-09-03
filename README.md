# placecal-theme-transdimension

The Trans Dimension theme for [PlaceCal](https://github.com/geeksforsocialchange/PlaceCal), packaged as a PlaceCal extension (a Rails engine). It provides the theme, homepage, static page content, copy, fonts and illustrations for [transdimension.uk](https://transdimension.uk), which is served by PlaceCal.

Extensions contain no models, no migrations and no business logic. See PlaceCal's `doc/extensions.md` for the extension contract.

## Layout

```
lib/transdimension.rb              Module and Phlex namespaces
lib/transdimension/engine.rb       Autoload dirs and theme registration
app/views/transdimension/          Phlex views (Transdimension::Views)
app/components/transdimension/     Phlex components (Transdimension::Components)
app/tailwind/theme.css             Tailwind source
app/assets/builds/transdimension/  Built CSS, committed, served by Propshaft
config/locales/en.yml              Theme strings, namespaced under transdimension.*
config/locales/overrides.en.yml    Overrides of core strings, appended after core's locales
content/                           Static page content, rendered by the views above
doc/visual-diff.md                 Open deviations from the live site, with reasons
doc/audits/                        Legacy URL audit: path list, task output tables
```

The reference screenshots of the live site live in `goldens/`, which is gitignored: they are large PNGs of a site we do not own, and they are a working artifact rather than a deliverable. Recapture them locally with `bash goldens/capture.sh` (the script is kept alongside them, so it is local too). The durable record of the comparison is `doc/visual-diff.md`, which is committed.

There are deliberately no models, migrations, controllers or routes. Every visible string goes through `t()`.

## Installation

Add the engine to the PlaceCal installation's `Gemfile`, pinned to a tag, in the single removable extensions block described in core's `doc/extensions.md`:

```ruby
# Installation-specific extensions for placecal.org. Not part of core: a
# self-hosted PlaceCal can delete this block.
group :extensions do
  gem 'placecal-theme-transdimension',
      github: 'geeksforsocialchange/placecal-theme-transdimension',
      tag: 'v0.3.8'
end
```

The CSS is committed prebuilt, so core's Docker build needs no extra Node step.

### Minimum core

The host has to be a PlaceCal with the extension theme registry, that is core with #3368 merged. Specifically, `PlaceCal::Extensions.register_theme` must exist and the theme it yields must support every setting this engine uses:

`stylesheet`, `homepage_view`, `head`, `footer`, `event_filter_style`, `nav_cta`, `nav_join`, `map_style`

The engine checks this while it registers, and raises `Transdimension::UnsupportedHost` naming the missing capability rather than failing with a `NoMethodError` from inside an initializer. `Transdimension::Engine::REQUIRED_THEME_SETTINGS` is the list it checks.

`menu_label`, `icons`, `mask_icon_color`, `theme_color`, `background_color`, `og_image` and `page` are set the same way but are not required: each is applied only when the host's `PlaceCal::Theme` responds to it. An older core keeps its own mobile menu affordance and favicon, and simply has no `/about` (it falls back to its own `/privacy` markdown).

## Development

The specs boot the PlaceCal core application with this engine loaded, so they need a checkout of core and core's gem bundle. Check core out next to this repo (the default core path is `../PlaceCal`, override it with `PLACECAL_CORE_PATH`).

Core's own `Gemfile` pins this engine to a git tag, which would run the specs against the released gem rather than your working tree. So point Bundler at a Gemfile that swaps that pin for a `path:` entry. Create `Gemfile.td-dev` in the core checkout (do not commit it; add it to core's `.git/info/exclude`):

```ruby
# Local-only Gemfile: core with the TD extension from the sibling path checkout
# instead of the pinned git tag.
core = File.read(File.expand_path('Gemfile', __dir__))
core = core.sub(/^group :extensions do.*?^end\n/m, '')
instance_eval(core, File.expand_path('Gemfile', __dir__), 1)
gem 'placecal-theme-transdimension', path: '../placecal-theme-transdimension'
```

Then run the specs against it:

```sh
cd /path/to/placecal-theme-transdimension
PLACECAL_CORE_PATH=/path/to/PlaceCal \
  BUNDLE_GEMFILE=/path/to/PlaceCal/Gemfile.td-dev \
  RAILS_ENV=test bundle exec rspec
```

`spec/rails_helper.rb` aborts with an explanatory message if the booted engine is not this working tree, so a stale Gemfile fails loudly instead of quietly testing the installed tag.

This engine's own `Gemfile` exists for gem metadata and tooling; it cannot resolve the gems core needs to boot, which is why the invocations above point Bundler at core. RuboCop runs the same way:

```sh
BUNDLE_GEMFILE=/path/to/PlaceCal/Gemfile.td-dev bundle exec rubocop
```

`.github/workflows/test.yml` runs the same two commands, against a Gemfile it builds the same way.

### Releasing

Installations pin this engine by tag, so a release is a version bump followed by a tag. Bump `lib/transdimension/version.rb` and `package.json` together (a spec fails if they disagree, or if the latest tag is ahead of `VERSION`), merge, then tag the merge commit `v<version>`. CI fails a tag push whose tag name does not match `VERSION`.

### Tailwind

The theme's CSS is built by `@tailwindcss/cli` from `app/tailwind/theme.css`, scanning only this engine's views and components, into `app/assets/builds/transdimension/theme.css`. That build is committed and CI fails when it is stale.

```sh
yarn install
yarn build      # rebuild the committed CSS
yarn run check  # fail if the committed CSS is stale
```

Use `yarn run check` rather than `yarn check`: `check` is also a built-in Yarn command, and the built-in wins.

### Static pages

This engine bundles Trans Dimension's static page content (About, Privacy) as markdown in `content/`, and renders it itself: `Transdimension::Views::About` and `Transdimension::Views::Privacy` compose the markdown files with the section headings from `config/locales/en.yml`. Nothing is seeded into the host database and there is no page admin to keep in sync.

The engine registers the two pages while it registers the theme:

```ruby
theme.page 'about', 'Transdimension::Views::About', nav_label_key: 'transdimension.nav.about'
theme.page 'privacy', 'Transdimension::Views::Privacy'
```

Core serves each at `/<slug>` on sites using the theme, lists the ones with a `nav_label_key` in the derived navigation, and includes both in the site sitemap. About carries a nav label; Privacy does not, because the footer carries that link. `privacy` is the one core route a theme page may replace.

Editing the copy means editing the markdown in `content/` and shipping a release. Rendered HTML is memoised per file on the view class and keyed on the file's mtime, so a content edit shows up in development without a restart and production parses each file once.

## URL audit

`doc/audits/` holds the record of checking every legacy Trans Dimension URL against PlaceCal: the path list, and a dated markdown table per run. The `transdimension:url_audit` rake task regenerates a table, checking each path against the live Trans Dimension site, production PlaceCal, and a local dev server running the branch under test.

```sh
bundle exec rake transdimension:url_audit
```

Each host is read from the environment, so the task can point anywhere: `TD_BASE_URL`, `PC_BASE_URL`, `DEV_BASE_URL` (set it to an empty string to skip the dev column), `AUDIT_ROUTE_HOST`, `AUDIT_URLS_FILE` and `AUDIT_OUTPUT_DIR`. The defaults are the Trans Dimension ones.

## Site record setup

Creating the Trans Dimension Site record in PlaceCal requires root admin access. See `doc/site-record.md` for step-by-step instructions on configuring the Site, tags, images and contact email.

After creating the site, verify it is configured correctly by running the check task.

```sh
bundle exec rake transdimension:check[site-slug]
```

The site slug is optional: without it the task falls back to `TD_SITE_SLUG`, and then to `trans-dimension`.

The task prints PASS, WARN and FAIL lines for each required field and exits non-zero if any check fails. The neighbourhood check follows `doc/site-record.md`: a single country-unit neighbourhood passes, anything else warns without failing.

## Copyright and licence

The code in this repository is licensed under the [Hippocratic License 3.0](LICENSE).

The design assets in this repository (illustrations, logos, artwork and brand copy) are copyright [Gendered Intelligence](https://genderedintelligence.co.uk). They are included here so that the Trans Dimension site can be served by PlaceCal, and they may not be reused outside that context without Gendered Intelligence's permission.

The favicons in `app/assets/images/transdimension/favicons/` and the share image `app/assets/images/transdimension/og-share.png` are Gendered Intelligence's too, taken from the live [transdimension.uk](https://transdimension.uk) so that a PlaceCal-served site keeps the same browser tab icon, home screen icon and link preview.

No font files are in this repository. The theme's typeface is Covik Sans, loaded at runtime from [Adobe Fonts](https://fonts.adobe.com) (Typekit kit `qwi3qrw`, linked by `app/components/transdimension/head.rb`) and licensed through Adobe Fonts by the site owner. An installation serving a different site needs its own Adobe Fonts licence and kit.

Illustrations by [Harry Woodgate](https://www.harrywoodgate.com/). Site design by [Squid](https://studiosquid.co.uk/).
