# placecal-theme-transdimension

The Trans Dimension theme for [PlaceCal](https://github.com/geeksforsocialchange/PlaceCal), packaged as a PlaceCal extension (a Rails engine). It provides the theme, homepage, static page content, copy, fonts and illustrations for [transdimension.uk](https://transdimension.uk), which is served by PlaceCal.

Extensions contain no models, no migrations and no business logic. See PlaceCal's `doc/extensions.md` for the extension contract.

## Layout

```
lib/transdimension.rb              Module and Phlex namespaces
lib/transdimension/engine.rb       Autoload dirs, theme registration, locale overrides
app/views/transdimension/          Phlex views (Transdimension::Views)
app/components/transdimension/     Phlex components (Transdimension::Components)
app/tailwind/theme.css             Tailwind source
app/assets/builds/transdimension/  Built CSS, committed, served by Propshaft
config/locales/en.yml              Theme strings, namespaced under transdimension.*
config/locales/overrides.en.yml    Overrides of core strings, appended after core's locales
content/                           Static page content
goldens/                           Reference screenshots of the current live site
```

There are deliberately no models, migrations, controllers or routes. Every visible string goes through `t()`.

## Installation

Add the engine to the PlaceCal installation's `Gemfile`, pinned to a tag, in the single removable extensions block described in core's `doc/extensions.md`:

```ruby
# Installation-specific extensions for placecal.org. Not part of core: a
# self-hosted PlaceCal can delete this block.
group :extensions do
  gem 'placecal-theme-transdimension',
      github: 'geeksforsocialchange/placecal-theme-transdimension',
      tag: 'v0.1.0'
end
```

The CSS is committed prebuilt, so core's Docker build needs no extra Node step.

## Development

The specs boot the PlaceCal core application with this engine loaded, so they need a checkout of core and core's gem bundle. Check core out next to this repo (the default core path is `../PlaceCal`, override it with `PLACECAL_CORE_PATH`) and run the specs against core's `Gemfile`:

```sh
cd /path/to/placecal-theme-transdimension
BUNDLE_GEMFILE=/path/to/PlaceCal/Gemfile RAILS_ENV=test bundle exec rspec
```

This engine's own `Gemfile` exists for gem metadata and tooling; it cannot resolve the gems core needs to boot, which is why the invocation above points Bundler at core. RuboCop runs the same way:

```sh
BUNDLE_GEMFILE=/path/to/PlaceCal/Gemfile bundle exec rubocop
```

Both are what `.github/workflows/test.yml` runs.

### Tailwind

The theme's CSS is built by `@tailwindcss/cli` from `app/tailwind/theme.css`, scanning only this engine's views and components, into `app/assets/builds/transdimension/theme.css`. That build is committed and CI fails when it is stale.

```sh
yarn install
yarn build      # rebuild the committed CSS
yarn run check  # fail if the committed CSS is stale
```

Use `yarn run check` rather than `yarn check`: `check` is also a built-in Yarn command, and the built-in wins.

## Copyright and licence

The code in this repository is licensed under the [Hippocratic License 3.0](LICENSE).

The design assets in this repository (illustrations, logos, artwork and brand copy) are copyright [Gendered Intelligence](https://genderedintelligence.co.uk). They are included here so that the Trans Dimension site can be served by PlaceCal, and they may not be reused outside that context without Gendered Intelligence's permission.

Illustrations by Harry Woodgate.
