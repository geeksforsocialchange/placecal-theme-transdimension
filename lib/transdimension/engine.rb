# frozen_string_literal: true

require 'yaml'

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

    # Theme settings that are really copy (the Donate URL) belong in the locale
    # file, but the engine's locales are not on I18n.load_path yet while
    # initializers run, and calling I18n.t here would resolve to nothing and
    # initialise the backend early. Read the YAML directly instead; the specs
    # assert the two sources agree.
    def self.locale_value(key)
      @locale ||= YAML.load_file(root.join('config/locales/en.yml')).fetch('en')
      key.to_s.split('.').reduce(@locale) { |node, part| node.fetch(part) }
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
        theme.nav_cta 'transdimension.header.donate', Engine.locale_value('transdimension.header.donate_url')
        # PageHeader.elm has no Join link; PageFooter.elm carries it instead
        theme.nav_join false
        # Pink-tinted OpenFreeMap style shipped with the engine
        theme.map_style 'transdimension'
        # PageHeader.elm labels the mobile toggle "Menu" rather than drawing a
        # hamburger. Guarded: cores without the setting simply keep their own.
        theme.menu_label true if theme.respond_to?(:menu_label)

        # Favicons, touch icon, Safari mask icon and manifest icons, copied
        # from the live transdimension.uk (#3368 WP 3.10). Guarded so a core
        # without the icon DSL still boots on its own favicon.
        if theme.respond_to?(:icons)
          theme.icons favicon_32: 'transdimension/favicons/favicon-32x32.png',
                      favicon_16: 'transdimension/favicons/favicon-16x16.png',
                      apple_touch_icon: 'transdimension/favicons/apple-touch-icon.png',
                      mask_icon: 'transdimension/favicons/safari-pinned-tab.svg',
                      icon_192: 'transdimension/favicons/android-chrome-192x192.png',
                      icon_512: 'transdimension/favicons/android-chrome-512x512.png'
        end
        # site.webmanifest on the live site: mask #FF7AA7, theme #ff7aa7,
        # splash background the dark blue the brand sits on.
        theme.mask_icon_color '#FF7AA7' if theme.respond_to?(:mask_icon_color)
        theme.theme_color '#ff7aa7' if theme.respond_to?(:theme_color)
        theme.background_color '#040f39' if theme.respond_to?(:background_color)
        # The live site's share image (tdd_logo_with_strapline_on_darkBlue.png).
        # Its real pixel size is 556x320; the live site's own og:image:width and
        # og:image:height say 1200x675, which the bytes do not bear out, so the
        # declared size here is the file's actual one.
        theme.og_image 'transdimension/og-share.png', width: 556, height: 320 if theme.respond_to?(:og_image)
      end
    end
  end
end
