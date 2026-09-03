# frozen_string_literal: true

module Transdimension
  # Raised when the host PlaceCal is too old to serve this theme.
  class UnsupportedHost < StandardError; end

  class Engine < ::Rails::Engine
    # Not isolate_namespace: an extension plugs into the host app's routes,
    # helpers and layout rather than living behind a mount point.

    # Rails does not autoload app/views, and it autoloads app/components under
    # the top-level namespace, so the engine pushes its own directories with
    # explicit namespaces. Core does the same for Views and Components in
    # config/initializers/phlex.rb.
    initializer 'transdimension.phlex_namespaces', before: :set_autoload_paths do
      Rails.autoloaders.main.push_dir(
        root.join('app/views/transdimension'),
        namespace: Transdimension::Views
      )
      Rails.autoloaders.main.push_dir(
        root.join('app/components/transdimension'),
        namespace: Transdimension::Components
      )
    end

    # Every theme DSL setting this engine uses. The host has to provide all of
    # them; see "Minimum core" in the README.
    REQUIRED_THEME_SETTINGS = %i[
      stylesheet homepage_view head footer event_filter_style nav_cta nav_join map_style
    ].freeze

    # An older core has no extension registry, or a registry whose Theme is
    # missing settings added later. Either way the failure would otherwise be a
    # bare NoMethodError raised from inside an initializer, which says nothing
    # about what the installation needs. Name the missing capability instead.
    def self.verify_host!(registry = host_registry)
      return if registry.respond_to?(:register_theme)

      raise UnsupportedHost,
            'PlaceCal::Extensions.register_theme is not available: this theme needs a PlaceCal ' \
            'with the extension theme registry (see "Minimum core" in the engine README).'
    end

    def self.verify_theme!(theme)
      missing = REQUIRED_THEME_SETTINGS.reject { |setting| theme.respond_to?(setting) }
      return if missing.empty?

      raise UnsupportedHost,
            "PlaceCal::Theme does not support #{missing.join(', ')}: this theme needs a newer " \
            'PlaceCal (see "Minimum core" in the engine README).'
    end

    # Favicons, touch icon, Safari mask icon, manifest colours and share card,
    # copied from the live transdimension.uk (#3368 WP 3.10). Every setting is
    # guarded so a core without the icon DSL still boots on its own favicon.
    # PageHeader.elm: the Donate button at the end of the nav goes to the
    # Partnership's Donorbox page. A URL is not a UI string, so it is a constant
    # here rather than a locale key; only the button label is translated.
    DONATE_URL = 'https://donorbox.org/the-trans-dimension'

    ICONS = {
      favicon_32: 'transdimension/favicons/favicon-32x32.png',
      favicon_16: 'transdimension/favicons/favicon-16x16.png',
      apple_touch_icon: 'transdimension/favicons/apple-touch-icon.png',
      mask_icon: 'transdimension/favicons/safari-pinned-tab.svg',
      icon_192: 'transdimension/favicons/android-chrome-192x192.png',
      icon_512: 'transdimension/favicons/android-chrome-512x512.png',
      # site.webmanifest on the live site: the Safari pinned-tab mask colour.
      # Core takes it in the icons hash rather than as a setting of its own.
      mask_icon_color: '#FF7AA7'
    }.freeze

    def self.register_branding(theme)
      theme.icons(**ICONS)
      # site.webmanifest on the live site: theme #ff7aa7, splash background the
      # dark blue the brand sits on.
      theme.theme_color '#ff7aa7' if theme.respond_to?(:theme_color)
      theme.background_color '#040f39' if theme.respond_to?(:background_color)
      # Share card: the live site's logo artwork (556x320) centred on TD dark
      # blue at 1200x630, the size Facebook and Twitter want for a large card.
      # The live site links the bare 556x320 file while claiming 1200x675.
      theme.og_image 'transdimension/og-share.png', width: 1200, height: 630 if theme.respond_to?(:og_image)
    end

    # The theme's own static pages (#3368 WP 3.12). Content lives in this
    # engine's content/ directory and is rendered by the theme's own views, so
    # nothing has to be seeded into the host database. About carries a nav
    # label; Privacy does not, because PageFooter.elm puts the Privacy link in
    # the footer and the header has never shown it.
    #
    # Guarded rather than required: a core without the page DSL still boots on
    # its own /privacy markdown and simply has no /about.
    def self.register_pages(theme)
      return unless theme.respond_to?(:page)

      theme.page 'about', 'Transdimension::Views::About', nav_label_key: 'transdimension.nav.about'
      theme.page 'privacy', 'Transdimension::Views::Privacy'
    end

    def self.host_registry
      defined?(::PlaceCal::Extensions) ? ::PlaceCal::Extensions : nil
    end

    # Theme registration (#3368 D1). Runs before core's config/initializers,
    # which is why core requires the registry from config/application.rb.
    initializer 'transdimension.register_theme' do
      Engine.verify_host!

      PlaceCal::Extensions.register_theme(:transdimension) do |theme|
        Engine.verify_theme!(theme)

        theme.stylesheet 'transdimension/theme'
        theme.homepage_view 'Transdimension::Views::Home'
        theme.head 'Transdimension::Components::Head'
        theme.footer 'Transdimension::Components::Footer'
        theme.event_filter_style :day_strip
        # PageHeader.elm: the Donate button (PHT Donorbox) at the end of the nav
        theme.nav_cta 'transdimension.header.donate', DONATE_URL
        # PageHeader.elm has no Join link; PageFooter.elm carries it instead
        theme.nav_join false
        # Pink-tinted OpenFreeMap style shipped with the engine
        theme.map_style 'transdimension'
        # PageHeader.elm labels the mobile toggle "Menu" rather than drawing a
        # hamburger. Guarded: cores without the setting simply keep their own.
        theme.menu_label true if theme.respond_to?(:menu_label)

        Engine.register_branding(theme)
        Engine.register_pages(theme)
      end
    end
  end
end
